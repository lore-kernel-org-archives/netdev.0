From: kuznet@ms2.inr.ac.ru
Subject: Re: RFC 3484 support
Date: Thu, 13 Nov 2003 13:07:57 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311131007.NAA23770@yakov.inr.ac.ru>
References: <3FB18758.8040708@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: drepper@redhat.com (Ulrich Drepper)
In-Reply-To: <3FB18758.8040708@redhat.com> from "Ulrich Drepper" at Ноя 11, 2003 05:05:28 
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> To sort the destination addresses the source address for each of the
> addresses returned by getaddrinfo must be determined.  This can be done
> in two ways:
> 
> 1. use the existing kernel functionality and provide an interface to it
>    which userlevel can use

This interface is connect() for example. Essentially, connect() on
datagram socket with subsequent getsockname() makes exactly this.


> #2 above has serious problems.

This is just impossible.

> the kernel?  Could we get a syscall or whatever to pass down to the
> kernel a set of addresses (and whatever else is needed) and the kernel
> passing back information about the sorted list (either the sorting list
> or a transformation description of some sort)?

Do you really need this?

Right now the kernel is able to to determine a valid source address
derived from some known destination address and nothing more. It is
just connect().

I do not understand rfc3484, actually. Does it involve some policies made
inside libc, which could contradict to policies used by kernel? If so,
it is definitely unimplementable without surgery in the kernel.

Alexey
