From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing, version 1
Date: Thu, 31 Oct 2002 04:59:09 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031045909.A15756@almesberger.net>
References: <20021031000249.A20233@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20021031000249.A20233@almesberger.net>; from wa@almesberger.net on Thu, Oct 31, 2002 at 12:02:49AM -0300
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

A little update:

http://www.almesberger.net/tcpcp/tcpcp-1.tar.gz

This one gets timestamps right, but needs to change a few things
in the rest of TCP. I've also added a Web server demo application.

- Werner

----------------------------------- CHANGES -----------------------------------

Version 1 (31-OCT-2002)
-----------------------

- tcpcp_hooks now try to load the tcpcp module
- added ts_offset to struct tcp_opt and related structures, so that tcpcp can
  adjust local timestamps on a per-socket basis
- added app/sendcp, a simple Web server with connection passing
- /proc/sys/net/ipv4/sysctl_privileged was not created when using tcpcp as a
  module

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
