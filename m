From: Eric Lemoine <Eric.Lemoine@Sun.COM>
Subject: sendfile() & unlink()
Date: Thu, 01 May 2003 19:28:05 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030501172805.GB4580@udine>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

What happens when unlink()ing a file that has just been sendfile()d? Is
there any guarantee that the file remains in the buffer cache while TCP
completes the xmit?

Thx.

-- 
Eric
