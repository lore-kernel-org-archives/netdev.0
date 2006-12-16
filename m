From: Erik Andersen <andersen@codepoet.org>
Subject: Re: [patch] scrub non-__GLIBC__ checks in linux/socket.h and linux/stat.h
Date: Sat, 16 Dec 2006 11:57:26 -0700
Message-ID: <20061216185726.GA17496@codepoet.org>
References: <8bd0f97a0612161042g3b61d42csd54cae46e4864f30@mail.gmail.com>
Reply-To: andersen@codepoet.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	viro@zeniv.linux.org.uk, Alexey Dobriyan <adobriyan@gmail.com>,
	"Robert P. J. Day" <rpjday@mindspring.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965412AbWLPS52@vger.kernel.org>
To: Mike Frysinger <vapier.adi@gmail.com>
Content-Disposition: inline
In-Reply-To: <8bd0f97a0612161042g3b61d42csd54cae46e4864f30@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat Dec 16, 2006 at 01:42:11PM -0500, Mike Frysinger wrote:
> On 11/30/06, Robert P. J. Day <rpjday@mindspring.com> wrote:
> >but there are a few other
> >cases which still contain compound preprocessor directives such as:
> >
> >  #if defined(__KERNEL__) || !defined(__GLIBC__) || (__GLIBC__ < 2)
> >
> >having never worked with unifdef before, i guess i was being overly
> >optimistic in thinking that it, if i "unifdef"ed __KERNEL__, it might
> >at least simplify the expression.  oh, well ... live and learn.
> 
> userspace should be worrying about userspace, so having the socket.h
> and stat.h pollute the namespace in the non-glibc case is wrong and
> pretty much prevents any other libc from utilizing these headers
> sanely unless they set up the __GLIBC__ define themselves (which
> sucks)
> -mike

Ack from me.  I'd love to see this applied so uClibc could
stop have to define __GLIBC__

 -Erik

--
Erik B. Andersen             http://codepoet-consulting.com/
--This message was written using 73% post-consumer electrons--
