From: Jeff Garzik <jgarzik@pobox.com>
Subject: Additional 802.11 net stack code posted
Date: Thu, 03 Jun 2004 02:53:48 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40BECAFC.7040405@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


One of things that a proper "802.11 stack" should be is tie closely into 
the core net stack, so that translation to/from 802.3 isn't going on all 
the time.  One wants to create, receive, and "understand" native 802.11 
frames, and provide a sane management infrastructure.

To that end, I ask that wireless hackers please study stub 802.11 code 
that DaveM wrote, posted at

http://www.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/davem-p80211.tar.bz2
