From: kuznet@ms2.inr.ac.ru
Subject: Re: Linux 2.6.0-test9
Date: Mon, 27 Oct 2003 22:36:21 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310271936.WAA07348@yakov.inr.ac.ru>
References: <Pine.LNX.4.44.0310261607230.3157-100000@home.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, Andries.Brouwer@cwi.nl,
        linux-kernel@vger.kernel.org (Kernel Mailing List), netdev@oss.sgi.com,
        davem@redhat.com (David S. Miller), kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@osdl.org (Linus Torvalds)
In-Reply-To: <Pine.LNX.4.44.0310261607230.3157-100000@home.osdl.org> from "Linus Torvalds" at Oct 26, 2003 04:21:59 PM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> And Alexey apparently tried to do the "FIXME" part, but without thinking 
> about the SIGURG part.

Actually, it was thought a lot for several linux-2.x. :-)


> We _need_ to stop at urgent data and we _should_ return -EINTR, and let
> the SIGURG handler do the URG read. Otherwise we'll lose urgent data (or
> we'll just read it inline without realizing that it was urgent data).

The patch was expected not to break this property. Alas, something
is overlooked yet. I still do not understand what exactly is broken,
I feel I have to find some rlogin to experiment in vivo.

Alexey
