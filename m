From: Mads Martin =?iso-8859-1?Q?J=F8rgensen?= <mmj@suse.de>
Subject: Re: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 15:35:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716133514.GB7184@suse.de>
References: <20030716092354.GC24077@suse.de> <20030716054255.1922d299.davem@redhat.com> <20030716125910.GB10817@suse.de> <20030716061013.64f14a04.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030716061013.64f14a04.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* David S. Miller <davem@redhat.com> [Jul 16. 2003 15:21]:
> > > That is why all of this is rediculious.
> > 
> > Problem is some of these includes are different on different archs, and
> > causes the thing to miscompile. How to fix that then?
> 
> Nothing arch specific resides in linux/if.h :-)
> 
> This means the problem eminates from asm/*.h headers which is
> where the fixes belong.

Yes. What fix, would you propose?

> What exactly is the error you get on ia64?

a bunch of compile errors like the following:

In file included from /usr/src/linux/include/asm/system.h:19,
                 from /usr/src/linux/include/asm/atomic.h:17,
                 from /usr/src/linux/include/linux/netdevice.h:32,
                 from /usr/src/linux/include/linux/if_arp.h:26,
                 from ifenslave.c:91:
/usr/src/linux/include/asm/pal.h:89: parse error before "pal_status_t"
/usr/src/linux/include/asm/pal.h:89: warning: type defaults to `int' in 
declaration of `pal_status_t'
/usr/src/linux/include/asm/pal.h:89: warning: data definition has no
type or storage class
/usr/src/linux/include/asm/pal.h:102: parse error before
"pal_cache_level_t"
/usr/src/linux/include/asm/pal.h:102: warning: type defaults to `int' in 

declaration of `pal_cache_level_t'
/usr/src/linux/include/asm/pal.h:102: warning: data definition has no
type or 
storage class
/usr/src/linux/include/asm/pal.h:110: parse error before
"pal_cache_type_t"
/usr/src/linux/include/asm/pal.h:110: warning: type defaults to `int' in 
declaration of `pal_cache_type_t'
/usr/src/linux/include/asm/pal.h:110: warning: data definition has no
type or storage class
/usr/src/linux/include/asm/pal.h:123: parse error before
"pal_cache_line_state_t

etc.

thanks,
-- 
Mads Martin Joergensen, http://mmj.dk
"Why make things difficult, when it is possible to make them cryptic
 and totally illogical, with just a little bit more effort?"
                                -- A. P. J.
