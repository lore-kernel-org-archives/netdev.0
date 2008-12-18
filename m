From: "karthikeyan S" <karthispeaks@gmail.com>
Subject: packets dropped after send returns success
Date: Fri, 19 Dec 2008 01:20:48 +0530
Message-ID: <3bedf6ab0812181150hb94e007gae8950b9b8a2c1a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:7909 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751568AbYLRTut (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2008 14:50:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am facing an issue with a linux box (a wireless lan controller),
would like to have suggestions from you.
The controller sends a mobility udp ping request to it's mobility
members every 30 seconds upon receiving a ping request.
These ping responses are dropped randomly for unknown reasons (it runs
fine for 3-4 days then it experiences this problem for say 20 minutes
then resumes to normalcy)
This issue happens at the customer site and we haven't been able to
reproduce it in-house.

The mobility application sends the packet to the kernel using
sendmsg() and it returns success.What may be the possible reasons for
packets being dropped in kernel after sendmsg() returns success?
I don't think there are any routing issues. One possible reason that I
thought of is that the driver transmit queue is full.
But looks like other type of packets are going out of controller.
Could you plese provide your input? (kernel version is 2.4)

Thanks a lot.

-karthik
