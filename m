From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC 0/3] netlink: extended error reporting
Date: Fri, 07 Apr 2017 21:29:59 +0200
Message-ID: <1491593399.5800.14.camel@sipsolutions.net>
References: <1491591552.5800.1.camel@sipsolutions.net>
         <20170407190601.GA22991@salvia> <1491592185.5800.7.camel@sipsolutions.net>
         <20170407.122223.385211483743191711.davem@davemloft.net>
         <20170407192714.GA23349@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170407192714.GA23349@salvia>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-04-07 at 21:27 +0200, Pablo Neira Ayuso wrote:
> 
> > Also another way to look at this is that we're providing a lot of
> > new power and expressability.  So even if only one aspect of the
> > new error reporting is used it's a positive step forward.

True.

> > So allow offset "0" meaning "unspecified".
> 
> Instead, we can just not send the offset attribute to userspace if
> it's not specified. So missing attribute means "unspecified".
> 
> I'm always a bit worried this "0 means something" semantics :)

Yeah, I have that. If it's 0 internally the attribute will be omitted.

johannes
