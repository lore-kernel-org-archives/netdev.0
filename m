From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH 5/5] Solve host error problem in low performance embedded system when continune down and up.
Date: Mon, 2 Oct 2006 18:03:23 +0800
Message-ID: <024e01c6e609$fef98f60$4964a8c0@icplus.com.tw>
References: <1159813596.2576.8.camel@localhost.localdomain> <20061001235151.97ff6d11.akpm@osdl.org>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr45.hinet.net ([168.95.4.145]:53225 "EHLO msr45.hinet.net")
	by vger.kernel.org with ESMTP id S1750721AbWJBKDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Oct 2006 06:03:36 -0400
To: "Andrew Morton" <akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In some low performance embedded CPU, if continued to ifconfig up
and down driver. It will cause host error. Driver need to make sure all
counter is clear to zero, and hardware actually stop.

----- Original Message ----- 
From: "Andrew Morton" <akpm@osdl.org>
To: "Jesse Huang" <jesse@icplus.com.tw>
Cc: <linux-kernel@vger.kernel.org>; <netdev@vger.kernel.org>;
<jgarzik@pobox.com>
Sent: Monday, October 02, 2006 2:51 PM
Subject: Re: [PATCH 5/5] Solve host error problem in low performance
embedded system when continune down and up.


On Mon, 02 Oct 2006 14:26:36 -0400
Jesse Huang <jesse@icplus.com.tw> wrote:

> Solve host error problem in low performance embedded system when continune
down and up.

I don't understand that.  Please describe the actual problem which is being
solved,
as well as the means by which it was solved, thanks.


