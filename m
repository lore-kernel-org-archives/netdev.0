From: Wichert Akkerman <wichert@wiggy.net>
Subject: Minor error in debugging message
Date: Fri, 2 May 2003 11:12:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030502091203.GN22848@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I just noticed this in the 2.5.68 kernel boot sequence:

Freeing alive device d7e6a000, eth%d

It seems to be printed from netdev_finish_unregister (at least grep
doesn't find that message elsewhere) and dev->name contains eth%d
instead of eth0.

Wichert.

-- 
Wichert Akkerman <wichert@wiggy.net>      It is simple to make things.
http://www.wiggy.net/                     It is hard to make things simple.
