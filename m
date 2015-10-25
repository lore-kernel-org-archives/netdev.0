From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next v7 01/10] qed: Add module with basic common
 support
Date: Sun, 25 Oct 2015 06:18:51 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E53F6F@avmb3.qlogic.org>
References: <1445490417-8845-1-git-send-email-Yuval.Mintz@qlogic.com>
	<1445490417-8845-2-git-send-email-Yuval.Mintz@qlogic.com>
 <20151024.051149.1911984823506391327.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:61342 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750945AbbJYGSy convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Oct 2015 02:18:54 -0400
In-Reply-To: <20151024.051149.1911984823506391327.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > +/* counts the iids for the CDU/CDUC ILT client configuration */
> > +struct qed_cdu_iids {
> > +	u32	pf_cids;
> > +};

Actually, this will [in future] also include a `per_vf_cids' field;
I've extracted it and all its usages when preparing this patch series
[As our initial submission doesn't include IOV support].

I'd rather leave this as-is instead of making changes I'd have to revert
later on, but if your 'code buds' reject this, I'll make the change.
