From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Enabling standard compliant behaviour in the Linux TCP
 implementation
Date: Tue, 16 May 2006 13:51:56 -0700 (PDT)
Message-ID: <20060516.135156.61699813.davem@davemloft.net>
References: <8dd26e70605160724j784cf538v59631cf571646f36@mail.gmail.com>
	<20060516092407.68fbc205@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: angelo.castellani+lkml@gmail.com, netdev@vger.kernel.org,
	francesco@net.infocom.uniroma1.it, andrea.baiocchi@uniroma1.it
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:47248
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750772AbWEPUvu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 May 2006 16:51:50 -0400
To: shemminger@osdl.org
In-Reply-To: <20060516092407.68fbc205@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Tue, 16 May 2006 09:24:07 -0700

> Read Linus's comments on standards. We make software for users, not for
> academic use.
> 	http://kerneltrap.org/node/5725
> 
> If we added this then paranoid users would set it.

I totally agree, and naming this thing "standard_compliant" really
gives the wrong impression about the situation.

Every TCP stack out there has behaviorisms, like these, which
while not mentioned specifically in any standard are entirely
within the spirit of the standards and that is what matters.
