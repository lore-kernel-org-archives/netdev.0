From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 0/3] bonding: modify the current and add new
 hash functions
Date: Thu, 26 Sep 2013 01:56:41 +0200
Message-ID: <52437839.70707@redhat.com>
References: <1380133912-1240-1-git-send-email-nikolay@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andy@greyhouse.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:28601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061Ab3IYX4u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Sep 2013 19:56:50 -0400
In-Reply-To: <1380133912-1240-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Self-nack on this patchset as the flow_dissector patch will make nhoff
different from before, that is the port offset will not be added to it, and
thus will make flow_keys' th_off different in skb_flow_dissect.
Again, I will wait until tomorrow to see if there're any other comments and
will re-post a v3 with this bug fixed.

Nik
