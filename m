From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing, version 2
Date: Thu, 31 Oct 2002 20:00:17 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031200017.A21544@almesberger.net>
References: <20021031000249.A20233@almesberger.net> <20021031045909.A15756@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021031045909.A15756@almesberger.net>; from wa@almesberger.net on Thu, Oct 31, 2002 at 04:59:09AM -0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Another update:

http://www.almesberger.net/tcpcp/tcpcp-2.tar.gz

This one fixes window, MSS, and buffer space handling. I've also
added a bit of documentation describing how to use it properly.

- Werner

----------------------------------- CHANGES -----------------------------------

Version 2 (31-OCT-2002)
-----------------------

- removed 1000 "voodoo slack" term in __tcpcp_maxicisize's size estimate
- tcpcp.c:tcpcp_init now correctly identifies the version as the one of the ICI
  format, not as the one of tcpcp itself
- tcpcp.c:tcpcp_buffers checks send sequence numbers
- tcpcp.c:tcpcp_fixup adjusts receive buffer to advertized window
- tcpcp.c:tcpcp_fixup sets MSS clamp to value from ICI
- documented request_module race in tcpcp_hooks.c
- README and tcpcp.c: added discussion of usefulness of tcpcp_start
- added description of handover procedure in doc/README.HANDOVER
- minor cleanups here and there

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
