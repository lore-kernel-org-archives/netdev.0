From: Stephen Hemminger <shemminger@osdl.org>
Subject: Fw: 2.6.19-rc1: Volanomark slowdown
Date: Tue, 7 Nov 2006 11:25:55 -0800
Message-ID: <20061107112555.60b52715@freekitty>
Reply-To: Tim Chen <tim.c.chen@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:20880 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752449AbWKGT00 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 14:26:26 -0500
To: John Heffner <jheffner@psc.edu>,
	"David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Begin forwarded message:

Date: Tue, 07 Nov 2006 10:32:34 -0800
From: Tim Chen <tim.c.chen@linux.intel.com>
Newsgroups: linux.dev.kernel
Subject: 2.6.19-rc1: Volanomark slowdown



The patch

[TCP]: Send ACKs each 2nd received segment
commit: 1ef9696c909060ccdae3ade245ca88692b49285b
http://kernel.org/git/?
p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=1ef9696c909060ccdae3ade245ca88692b49285b

reduced Volanomark benchmark throughput by 10%.  
This is because Volanomark sends 
short message (<100 bytes) on its TCP
connections.  This patch increases the number of ACKs 
traffic by 3.5 times.  

By adopting this patch, we assume that with
small segment, having short delay is important 
enough that we are willing to reduce bandwidth 
with more ACKs.  

Is there any real application out there
that this new behavior could be a concern?

Tim 
-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/


-- 
Stephen Hemminger <shemminger@osdl.org>
