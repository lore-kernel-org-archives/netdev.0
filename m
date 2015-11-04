From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [patch -next] qlogic/qed: remove bogus NULL check
Date: Wed, 4 Nov 2015 13:31:51 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E68723@avmb3.qlogic.org>
References: <20151104132716.GD20966@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ariel Elior <Ariel.Elior@qlogic.com>,
	Dept-Eng Everest Linux L2 <everest-linux-l2@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:54871 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751398AbbKDNb4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2015 08:31:56 -0500
In-Reply-To: <20151104132716.GD20966@mwanda>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We check if "p_hwfn" is NULL and then dereference it in the error handling
> code.  I read the code and it isn't NULL so let's remove the check.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Our current interrupt handling logic is being uber-defensive. Thanks.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
