From: Andrew Morton <akpm@osdl.org>
Subject: Fw: [Bugme-new] [Bug 4430] New: Virtual interfaces cannot have
 their own mtu
Date: Fri, 1 Apr 2005 02:11:21 -0800
Message-ID: <20050401021121.76da449b.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: lukeross@sys3175.co.uk
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


hm, mtu is implemented in the device driver - you might be out of luck.


Begin forwarded message:

Date: Fri, 1 Apr 2005 02:01:19 -0800
From: bugme-daemon@osdl.org
To: bugme-new@lists.osdl.org
Subject: [Bugme-new] [Bug 4430] New: Virtual interfaces cannot have their own mtu


http://bugme.osdl.org/show_bug.cgi?id=4430

           Summary: Virtual interfaces cannot have their own mtu
    Kernel Version: kernel-2.6.9-1.6_FC2
            Status: NEW
          Severity: low
             Owner: acme@conectiva.com.br
         Submitter: lukeross@sys3175.co.uk


Distribution: Fedora Core 2,3
Hardware Environment: Broadcom gigabit card using tg3 (Tyan s2885 onboard)
Problem Description:

eth0 and eth0:1 cannot have different mtus. I have a jumbo-frame capable switch
with three devices plugged in. Two are PCs with jumbo-capable cards, the other
is a wireless router which isn't, and hangs if either PC attempts to discover
whether it can support jumbo frames.

To get the benefit of jumbo frames between the two PCs, I tried to set up eth0:1
- on a different subnet to the wireless router - on both PCs, and set the mtu of
the eth0:1 to 9000. However it is not possible to set the mtu for eth0:1 to 9000
without setting the mtu of eth0 to 9000 as well.

Also noted in http://xcat.org/pipermail/xcat-user/2003-April/002358.html

------- You are receiving this mail because: -------
You are on the CC list for the bug, or are watching someone who is.
