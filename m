From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: [PATCH 2.6] dev.c: clear SIOCGIFHWADDR buffer if !dev->addr_len
Date: Fri, 29 Oct 2004 22:09:36 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041030030936.GA25102@lists.us.dell.com>
References: <20041030013700.GA21540@lists.us.dell.com> <E1CNiOT-0008GU-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Content-Disposition: inline
In-Reply-To: <E1CNiOT-0008GU-00@gondolin.me.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 30, 2004 at 11:51:01AM +1000, Herbert Xu wrote:
> > s/dev_addr/addr_len in the comments above, that's the field we care
> > about being non-zero.
> 
> This still doesn't make sense.  What if dev->addr_len is less than the
> size of the buffer? The caller has to know what the length is anyway.

Ahh, indeed.  net-snmp has hard-coded the number 6 or uses the
definition of IFHWADDRLEN (from include/linux/if.h, a copy of which is
in /usr/include/linux/if.h of course) in several places for this.

> BTW, the ioctl interface is obsolete.  Please use the rtnetlink
> interface where dev->addr_len can be read properly.

More than I wanted to do tonight, but will investigate.

Thanks,
Matt

-- 
Matt Domsch
Sr. Software Engineer, Lead Engineer
Dell Linux Solutions linux.dell.com & www.dell.com/linux
Linux on Dell mailing lists @ http://lists.us.dell.com
