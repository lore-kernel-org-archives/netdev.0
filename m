From: Mads Martin =?iso-8859-1?Q?J=F8rgensen?= <mmj@suse.de>
Subject: Re: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 14:59:10 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716125910.GB10817@suse.de>
References: <20030716092354.GC24077@suse.de> <20030716054255.1922d299.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030716054255.1922d299.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <davem@redhat.com> [Jul 16. 2003 14:52]:
> This whole anti-kernel-headers-in-userspace thing is a
> total shamans dance and not founded in reality.

Urgs.

> Quick, answer this as fast as you can, where in the glibc headers can
> you get at the PFKEY and XFRM_NETLINK interface definitions to
> configure IPSEC stuff in the kernel?
> 
> BZZT, time is up, and I know you have no answer :-)

:-)

> That is why all of this is rediculious.

Problem is some of these includes are different on different archs, and
causes the thing to miscompile. How to fix that then?

-- 
Mads Martin Joergensen, http://mmj.dk
"Why make things difficult, when it is possible to make them cryptic
 and totally illogical, with just a little bit more effort?"
                                -- A. P. J.
