From: "Jesse Huang" <jesse@icplus.com.tw>
Subject: Re: [PATCH 6/6] IP100A Solve host error problem when in low	performance embedded
Date: Mon, 21 Aug 2006 15:28:34 +0800
Message-ID: <00d101c6c4f3$6aa0fbf0$4964a8c0@icplus.com.tw>
References: <1155841780.4532.21.camel@localhost.localdomain> <44E5A1E1.1060500@pobox.com>
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msr30.hinet.net ([168.95.4.130]:4570 "EHLO msr30.hinet.net")
	by vger.kernel.org with ESMTP id S965009AbWHUH2y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2006 03:28:54 -0400
To: "Jeff Garzik" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jeff:
> (4) are you certain that DMACtrl should be read as a 32-bit register?
> In other code, you treat it as a 16-bit register.

DMACtrl can read and write both in 16-bit and 32-bit. I will modify all
of then as 32-bit.

Thanks.

Jesse


