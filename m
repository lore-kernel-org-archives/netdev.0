From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 0/5] bonding: groundwork and initial conversion
 to RCU
Date: Thu, 01 Aug 2013 15:14:09 +0200
Message-ID: <51FA5F21.3080700@redhat.com>
References: <1375359029-25889-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, davem@davemloft.net, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62450 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752647Ab3HANRq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Aug 2013 09:17:46 -0400
In-Reply-To: <1375359029-25889-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Self-nack, sorry for the noise but I found a problem with the new 3ad code, we
need to check if the list has been traversed when extracting the next port.

v3 will follow after I run some more tests.

Nik
