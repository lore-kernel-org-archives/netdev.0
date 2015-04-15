From: Stefan Bauer <sb@plzk.de>
Subject: [SOLVED]Re: ip link macvtap interface not processing specific ipv6
 multicast traffic without promiscuous mode on
Date: Wed, 15 Apr 2015 10:38:56 +0200
Message-ID: <1429087136.3383.39.camel@plzk.de>
References: <1428574167.2171.32.camel@plzk.de>
	 <1428598288.2759.2.camel@plzk.de> <1429086115.3383.36.camel@plzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay03.ispgateway.de ([80.67.31.41]:48455 "EHLO
	smtprelay03.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751509AbbDOIjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Apr 2015 04:39:00 -0400
Received: from [87.185.75.237] (helo=zarafa)
	by smtprelay03.ispgateway.de with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <sb@plzk.de>)
	id 1YiIq8-0003CO-7S
	for netdev@vger.kernel.org; Wed, 15 Apr 2015 10:38:32 +0200
Received: from s1 (unknown [192.168.0.151])
	by zarafa (Postfix) with ESMTP id 58210220064
	for <netdev@vger.kernel.org>; Wed, 15 Apr 2015 10:38:56 +0200 (CEST)
In-Reply-To: <1429086115.3383.36.camel@plzk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It was the privacy extension enabled on the windows hosts.

So it was sending out from addresses the KVM HOST is not member of the
multicast group.

disabled it with netsh interface ipv6 set privacy state=disabled

Stefan
