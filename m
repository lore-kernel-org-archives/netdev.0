From: Ben Greear <greearb@candelatech.com>
Subject: Make TCP work better with re-ordered frames?
Date: Wed, 18 May 2016 07:00:46 -0700
Message-ID: <573C758E.9050008@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:55143 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752494AbcEROAs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 10:00:48 -0400
Received: from [50.34.199.106] (unknown [50.34.199.106])
	(using TLSv1 with cipher ECDHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 77B6540A79A
	for <netdev@vger.kernel.org>; Wed, 18 May 2016 07:00:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are investigating a system that has fairly poor TCP throughput
with the 3.17 and 4.0 kernels, but evidently it worked pretty well
with 3.14 (I should be able to verify 3.14 later today).

One thing I notice is that a UDP download test shows lots of reordered
frames, so I am thinking maybe TCP is running slow because of this.

(We see about 800Mbps UDP download, but only 500Mbps TCP, even when
  using 100 concurrent TCP streams.)

Is there some way to tune the TCP stack to better handle reordered frames?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
