From: Cheng Jin <chengjin@cs.caltech.edu>
Subject: struct sock size limit?
Date: Sat, 26 Oct 2002 22:44:03 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.33L0.0210262236120.4401-100000@fast2.cs.caltech.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

I have been adding members to struct sock (by changing struct tcp_opt) in
linux 2.4.18-3 kernel.  I haven't had problems with the kernel until
today.   When I added a few more bytes (~ 20 bytes) on top of my old
addition (around 80 bytes), the kernel would crash calling udp_sendmsg
(syslogd initialization).  I suspect that there may be some kind of size
limit with struct sock/tcp_opt.  The TCP connected state is checked
from within udp_sendmsg (no idea why that is so).

I searched around on google, but didn't find anything on struct sock or
struct tcp_opt.  Does anyone know whether the size of struct sock/tcp_opt
is capped?

Thanks a lot,

Cheng

Lab # 626 395 8820
