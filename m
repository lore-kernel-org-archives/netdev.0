From: Jeff Garzik <jgarzik@pobox.com>
Subject: 2.7 net driver stuff
Date: Wed, 24 Mar 2004 12:57:35 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4061CC0F.6060201@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


An initial, quick FYI.  I'll be taking input for net drivers that can be 
removed in 2.7.  Even some of the ancient ISA net drivers still have users,

Other stuff:
* Would like to get rid of de4x5.c, but EISA support still has users 
that appear to care :)
* pondering importing Donald's myson driver, replacing unmaintained 
fealnx.c.  We have the new module_alias() stuff, which makes the 
transition a bit easier.

	Jeff
