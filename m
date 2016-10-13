From: Luca Coelho <luca-XPOmlcxoEMv1KXRcyAk9cg@public.gmane.org>
Subject: Re: [PATCH] iwlwifi: pcie: fix SPLC structure parsing
Date: Thu, 13 Oct 2016 14:30:22 +0300
Message-ID: <1476358222.3880.21.camel@coelho.fi>
References: <1476349269.3880.18.camel@coelho.fi>
         <20161013102155.14547-1-luca@coelho.fi>
         <1476358075.1999.5.camel@tiscali.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linuxwifi-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
        johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
        oren.givon-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        chris-FAYdYWbMHyxBDgjK7y7TUQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1476358075.1999.5.camel-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-10-13 at 13:27 +0200, Paul Bolle wrote:
> Luca,
> 
> On Thu, 2016-10-13 at 13:21 +0300, Luca Coelho wrote:
> > Could you please give this a spin? I have tested it with some handmade
> > ACPI tables in QEMU and it seems to work fine now.
> 
> 
> Tested-by: Paul Bolle <pebolle-IWqWACnzNjzz+pZb47iToQ@public.gmane.org>
> 
> Not that this test was worth a lot: it builds cleanly (on top of
> 4.8.1), the error at boot is gone, obviously, and wifi still works (as
> you're reading a message that was sent out over wifi). And I haven't
> even tested this on another machine than my XPS 13 (9350).

Thanks for testing!

I forgot to say... could you load the iwlwifi module with debug=0x01
(module parameter), so we can see the messages the driver is printing
when it doesn't find a proper structure?

--
Luca.
