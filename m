From: kuznet@ms2.inr.ac.ru
Subject: Re: RFC 3484 support
Date: Sat, 15 Nov 2003 02:45:46 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200311142345.CAA03631@yakov.inr.ac.ru>
References: <3FB40FE5.5040709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: drepper@redhat.com (Ulrich Drepper)
In-Reply-To: <3FB40FE5.5040709@redhat.com> from "Ulrich Drepper" at Nov 13, 2003 03:12:37 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Wouldn't this require to set up a socket and connect it to each target
> address?  The point of the whole source and destination address
> selection is it to avoid making connections

Datagram connect() is exactly selection of the addresses, nothing more.

I do not mind against specialized interface, but I still see plain
connect() as a reasonable and, the most important, universal solution.

> provided.  The address which has the highest rate of success and the
> highest quality for the connection should be tried first.

Hmm... We do not account for this. Do you really propose to gather
this kind of statistics in the kernel? I am afraid this is really difficult.

Alexey
