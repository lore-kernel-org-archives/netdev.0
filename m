From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing, version 4
Date: Fri, 15 Nov 2002 01:34:52 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021115013452.A11669@almesberger.net>
References: <20021031000249.A20233@almesberger.net> <20021031045909.A15756@almesberger.net> <20021031200017.A21544@almesberger.net> <20021101182123.A30594@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021101182123.A30594@almesberger.net>; from wa@almesberger.net on Fri, Nov 01, 2002 at 06:21:23PM -0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A minor update:

http://www.almesberger.net/tcpcp/tcpcp-4.tar.gz

The main changes are that TCP_KICK has turned into the slightly
more general TCP_CP_FN option, and that I've written down a few
thoughts on "real" checkpointing in doc/README.CHECKPOINTING

The funny thing is that, when I started writing, I suspected that
checkpointing wouldn't really be possible, but then I realized
how it might actually work (okay, with a few hacks, but ... ;-)

The patch is now relative to 2.5.47.

- Werner

----------------------------------- CHANGES -----------------------------------

Version 4 (15-NOV-2002)
-----------------------

- upgraded to the 2.5.47 kernel
- added doc/README.CHECKPOINTING with a few reflections on how tcpcp could be 
  abused for "real" checkpointing, where the previous connection owner suddenly
  dies
- renamed TCP_KICK to TCP_CP_FN, and added a sub-function code in optval
- renamed tcpcp_kick to tcpcp_activate

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
