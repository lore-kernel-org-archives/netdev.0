From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: panic on 2.6.11
Date: Fri, 4 Mar 2005 22:50:44 +0100
Message-ID: <20050304215044.GB1148@electric-eye.fr.zoreil.com>
References: <20050304132804.270cf05b@dxpl.pdx.osdl.net> <4228D523.2070703@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4228D523.2070703@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik <jgarzik@pobox.com> :
[...]
> Any idea what this BUG actually means?  Since it's in skb_over_panic(), 
> a function designed to do nothing but BUG(), that doesn't tell us a 
> whole lot about the callsite.

I have been reported that the driver is not protected against oversized
frames since 2.6.10 at least... I've just got an instant reboot on the
sparc box while testing it :o/

--
Ueimor
