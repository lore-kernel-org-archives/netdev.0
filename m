From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: pcie: fix SPLC structure parsing
Date: Thu, 13 Oct 2016 15:44:13 +0300
Message-ID: <1476362653.3880.25.camel@coelho.fi>
References: <1476349269.3880.18.camel@coelho.fi>
         <20161013102155.14547-1-luca@coelho.fi>
         <1476358075.1999.5.camel@tiscali.nl> <1476358222.3880.21.camel@coelho.fi>
         <1476362194.1999.11.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        oren.givon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        chris-FAYdYWbMHyxBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476362194.1999.11.camel-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-10-13 at 14:36 +0200, Paul Bolle wrote:
> On Thu, 2016-10-13 at 14:30 +0300, Luca Coelho wrote:
> > I forgot to say... could you load the iwlwifi module with debug=0x01
> > (module parameter), so we can see the messages the driver is printing
> > when it doesn't find a proper structure?
> 
> 
> That makes a lot of noise! Here's the first 100 lines or so, that
> apparently are generated directly after modprobing iwlwifi.
> 
> After these 100 lines there's a ten second gap (I guess it took me ten
> seconds to actually use the wifi). I assume you don't care about that
> part of the debug messages.
> 
> Have fun!

Thanks, Paul!

Yeah, this is the "INFO" debugging level and it is a sort of fallback
bucket when there is nothing more specific.  Sorry for that.


> <7>[  767.691342] iwlwifi 0000:3a:00.0: U iwl_pcie_prepare_card_hw iwl_trans_prepare_card_hw enter
> <7>[  767.691362] iwlwifi 0000:3a:00.0: U iwl_pcie_set_hw_ready hardware ready
> <7>[  767.692127] iwlwifi 0000:3a:00.0: U iwl_request_firmware attempting to load firmware 'iwlwifi-8000C-24.ucode'
> <7>[  767.692322] iwlwifi 0000:3a:00.0: U splc_get_pwr_limit No element for the WiFi domain returned by the SPLC method.

This is the line I was looking for. :) So everything looks fine now.
 Even though there is apparently something wrong with this part of the
ACPI table on you laptop, since it doesn't match our specifications.
 In any case, it's mostly harmless.

Thanks for the help!

--
Cheers,
Luca.
