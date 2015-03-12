From: David Miller <davem@redhat.com>
Subject: Re: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor
 PROPE state
Date: Thu, 12 Mar 2015 15:22:47 -0400 (EDT)
Message-ID: <20150312.152247.1607789216159086520.davem@redhat.com>
References: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, alexandre.dietsch@windriver.com,
	clinton.slabbert@windriver.com, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, netdev@vger.kernel.org,
	ulf.samuelsson@ericsson.com
To: Yanjun.Zhu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39245 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752142AbbCLTXc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Mar 2015 15:23:32 -0400
In-Reply-To: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Like Yoshifuji and others I agree that:

1) You can get working behavior by adjusting existing sysctls.

2) IPV4 ARP and IPV6 NDISC are not different in this regard.

I'm really tired of all of these ARP hacks being submitted recently,
and I want people to think more deeply about what they are proposing
first.
