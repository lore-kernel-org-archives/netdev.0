From: Andries.Brouwer@cwi.nl
Subject: Re: Linux 2.6.0-test9
Date: Sun, 26 Oct 2003 20:40:32 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <UTC200310261940.h9QJeWa04880.aeb@smtp.cwi.nl>
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andries.Brouwer@cwi.nl, torvalds@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

    From: Linus Torvalds <torvalds@osdl.org>

    > I have run 2.6.0-test6 without any problems. Switched
    > to 2.6.0-test9 today. Something involving job control
    > or so is broken. Several of my remote xterms hang.

    Btw, this one sounds like a known bug in bash.

No - it is a recent kernel bug.
Mikael Pettersson noticed precisely the same thing, and says
 "Reverting 2.6.0-test8-bk3's net/ipv4/tcp.c patch fixes
  these problems."
And so it does.

Andries
