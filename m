From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] TCP Veno module for kernel 2.6.16.13
Date: Thu, 25 May 2006 14:08:42 -0700 (PDT)
Message-ID: <20060525.140842.08324542.davem@davemloft.net>
References: <A975FFC51622704CBEAB749E263D1799015540B5@mail01.student.main.ntu.edu.sg>
	<20060525.132350.39157903.davem@davemloft.net>
	<20060525135011.470dc3dd@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ZHOU0022@ntu.edu.sg, baruch@ev-en.org, jmorris@namei.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:38797
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751261AbWEYVIh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 May 2006 17:08:37 -0400
To: shemminger@osdl.org
In-Reply-To: <20060525135011.470dc3dd@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@osdl.org>
Date: Thu, 25 May 2006 13:50:11 -0700

> The general idea of resetting cwnd to an estimate of capacity seems to
> be a general feature of Westwood, Veno, Compound and Africa. Also FreeBSD
> does the same thing, but they don't have a cool name.

Interesting point.

Eventually such an idea would need to be integrated into another
scheme such as CUBIC, instead of being an entirely different
congestion control scheme, if we ever want to have this facility
in a default congestion control algorithm.
