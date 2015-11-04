From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch -next] qlogic: qed: fix a test for MODE_MF_SI
Date: Wed, 4 Nov 2015 13:35:15 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E6873E@avmb3.qlogic.org>
References: <20151104132911.GE20966@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <everest-linux-l2@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:55387 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755787AbbKDNfU convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 08:35:20 -0500
In-Reply-To: <20151104132911.GE20966@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> MODE_MF_SI is 9.  We should be testing bit 9 instead of AND 0x9.
> 
> Fixes: fe56b9e6a8d9 ('qed: Add module with basic common support')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

True indeed. Thanks.
Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
