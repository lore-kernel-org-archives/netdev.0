From: Andrew Beverley <andy@andybev.com>
Subject: Meaning of "handle" when using tc filter ... flow hash
Date: Sun, 20 Nov 2011 09:00:41 +0000
Message-ID: <1321779641.2382.943.camel@andybev-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earth.simplelists.com ([89.16.184.171]:35201 "EHLO
	earth.simplelists.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751575Ab1KTJAj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 04:00:39 -0500
Received: from [10.0.12.81] (unknown [109.224.132.57])
	by earth.simplelists.com (Postfix) with ESMTPA id 4778A1B30037
	for <netdev@vger.kernel.org>; Sun, 20 Nov 2011 09:00:37 +0000 (GMT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I've been using the "flow hash keys" feature of tc to evenly distribute
bandwidth across client IP addresses.

In order to get it to work, I have to specify a "handle" value:

$TC filter add dev eth0 parent 4101: protocol ip \
	handle 10 flow hash keys dst divisor 1024

         ^^^^

However, the handle doesn't seem to do anything. No matter what value I
specify, the rule works. If I leave it out, I get an "RTNETLINK answers:
Invalid argument" error.

I would normally expect the handle parameter to specify a netfilter mark
value. In this case though, it doesn't seem to make any difference. Is
there a reason that it needs to be specified?

Thanks,

Andy
