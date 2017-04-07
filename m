From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 22:27:12 +0200
Message-ID: <1491596832.5800.21.camel@sipsolutions.net>
References: <20170407193550.GA23424@salvia>
         <20170407.124327.626442219286333933.davem@davemloft.net>
         <1491594406.5800.18.camel@sipsolutions.net>
         <20170407.125511.1233528940652477012.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407.125511.1233528940652477012.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-07 at 12:55 -0700, David Miller wrote:
> 
> One idea.  We use the macro thing to generate a "netlink.pot" file
> and then some userland tree can contain the latest netlink.pot and
> the translations.

Right. For the record - since we just talked about it - I was thinking
of putting it into a special section so that we could easily write a
script to generate the pot file from the kernel binary after doing
"allyesconfig" or collecting it from modules or so.

Thinking of modules though - do we need to adjust the module loading
code to load a new section? I'll have to look into that.

johannes
