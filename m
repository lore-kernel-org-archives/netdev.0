From: kuznet@ms2.inr.ac.ru
Subject: Re: Linux 2.6.0-test9
Date: Tue, 28 Oct 2003 21:25:15 +0300 (MSK)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200310281825.VAA23218@yakov.inr.ac.ru>
References: <3F9DBB7F.7030309@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@osdl.org (Linus Torvalds), akpm@osdl.org, Andries.Brouwer@cwi.nl,
        linux-kernel@vger.kernel.org (Kernel Mailing List), netdev@oss.sgi.com,
        davem@redhat.com (David S. Miller)
Return-path: <netdev-bounce@oss.sgi.com>
To: tommy.christensen@tpack.net (Tommy Christensen)
In-Reply-To: <3F9DBB7F.7030309@tpack.net> from "Tommy Christensen" at Oct 28, 2003 01:42:39 AM
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> I think the patch breaks things because it consumes (or rather skips)
> the urgent data ( in the code after the label found_ok_skb: ).
> 
> Since this happens before the SIGURG handler is run, it won't find
> any urgent data.
> 
> What do you think?

Yes, you are absolutely right. I missed exactly this thing.


> The patch by Linus seems to be fine though.

I think the patch suggested by Linus is 100% correct and
in fact it is the only solution.

Alexey
