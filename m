From: Werner Almesberger <wa@almesberger.net>
Subject: TCP connection passing
Date: Thu, 31 Oct 2002 00:02:49 -0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021031000249.A20233@almesberger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Here's something creepy for Halloween: a dirty little hack that 
allows you to pass TCP endpoints across hosts, across reboots, 
etc.

http://www.almesberger.net/tcpcp/tcpcp-0.tar.gz

(Includes a patch for 2.5.45, a bit of user space, and plenty of
documentation of its shortcomings. The patch is a bit deceptive:
in order to make timestamps work properly, more invasive changes
are needed.)

I got the idea for this hack while listening to Fabio Olive
Leite's talk about load-balancing at Linux-Kongress, but 
besides that, he's not to blame for it.

The implementation is a proof of concept, which is quite sloppy
with timestamps, MSS, window, etc., and don't even look at what 
it does to congestion control ...

Anyway, it seems to work, and it's fun to play with. 

- Werner

-- 
  _________________________________________________________________________
 / Werner Almesberger, Buenos Aires, Argentina         wa@almesberger.net /
/_http://www.almesberger.net/____________________________________________/
