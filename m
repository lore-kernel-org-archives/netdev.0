From: Andries.Brouwer@cwi.nl
Subject: Re: Linux 2.6.0-test9
Date: Mon, 27 Oct 2003 02:48:52 +0100 (MET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <UTC200310270148.h9R1mqO06057.aeb@smtp.cwi.nl>
Cc: Andries.Brouwer@cwi.nl, davem@redhat.com, kuznet@ms2.inr.ac.ru,
        linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: akpm@osdl.org, torvalds@osdl.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Andries, what was the situation that led to a TCP lockup?

rlogin followed by "emacs -nw".

rlogin uses SIGURG for communication.

It is not the TCP protocol that is locked up.
Keystrokes are transmitted and the results are sent back.
But the reader half of rlogin hangs.

Andries
