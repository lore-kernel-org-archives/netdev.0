From: Geoffrey Lee <glee@gnupilgrims.org>
Subject: Signal interrupt with connect.
Date: Tue, 15 Oct 2002 11:42:35 +0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015034235.GA15574@anakin.wychk.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,


A while ago, I have raised the issue of the interruptibility of
the connect() function.

We decided that a "restartable" connect() if interrupted by a signal
is the best solution.

I must apologize that I should have looked this up more carefully.

According to this document here (IEEE Std 1003.1-2001):

http://www.opengroup.org/onlinepubs/007904975/functions/connect.html

"If connect() is interrupted by a signal that is caught while blocked
waiting to establish a connection, connect() shall fail and set errno to
[EINTR], but the connection request shall not be aborted, and the
connection shall be established asynchronously."

so we must return -EINTR in the kernel.

Alexey, will you finally agree that we need to change this? :-)

(Yes, that sucks ... but ...)



	-- G.
	
