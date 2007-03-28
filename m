From: Steve Wise <swise@opengridcomputing.com>
Subject: netpoll question
Date: Wed, 28 Mar 2007 17:03:00 -0500
Message-ID: <1175119380.28767.4.camel@stevo-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-153-217-226.sw.biz.rr.com ([24.153.217.226]:33918 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933382AbXC1WDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Mar 2007 18:03:06 -0400
Received: from [172.16.0.69] (aoot.com [67.65.16.241])
	by smtp.opengridcomputing.com (Postfix) with ESMTP id 234D37C781
	for <netdev@vger.kernel.org>; Wed, 28 Mar 2007 17:03:04 -0500 (CDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey all,

I have netpoll question.  How does netpoll work with MSI/X, NAPI, and
nics that setup multiple RSS style receive queues for a single port?
>From what I can tell, if you're doing something like netdump using
netpoll for IO, then you might never process incoming packets that get
posted to the rx queues not associated with the main netdevice structure
because netpoll only calls the poll() function for the main netdev
struct.  Not the dummy netdevs setup for multiple rx queues.  

Is this the case or am I confused?

Thanks,


Steve.

