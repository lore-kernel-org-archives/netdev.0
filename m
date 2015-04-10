From: Ben Greear <greearb@candelatech.com>
Subject: EACCES sending UDP to broadcast address?
Date: Thu, 09 Apr 2015 18:04:44 -0700
Message-ID: <552721AC.9080900@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:51645 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751938AbbDJBEq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 21:04:46 -0400
Received: from [192.168.100.236] (unknown [50.251.239.81])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 7389A40EA62
	for <netdev@vger.kernel.org>; Thu,  9 Apr 2015 18:04:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'm running as root user, 4.0-rc6 + hack kernel.

User-space app is (or should be) trying to send a UDP frame
to 255.255.255.255 destination.

I am getting EACCESS from sendmmsg.

Is this expected?  Is there something even more special than root these
days?

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
