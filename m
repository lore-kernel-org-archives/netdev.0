From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: RX overrun errors building on several of our hosts
Date: Tue, 4 Aug 2015 11:39:27 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63DF6D71@avmb3.qlogic.org>
References: <DM2PR07MB670383331D9D645D83D9ADAF1770@DM2PR07MB670.namprd07.prod.outlook.com>
 <DM2PR07MB670C5AE859AC24DB9AAF869F1770@DM2PR07MB670.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: Dan Finn <Dan.Finn@plansource.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:52763 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932678AbbHDLjb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Aug 2015 07:39:31 -0400
In-Reply-To: <DM2PR07MB670C5AE859AC24DB9AAF869F1770@DM2PR07MB670.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> After implementing a new monitoring tool I've noticed that several of our
> physical servers have increasing RX errors, all seem to be classified as overruns.

Just to be sure we're looking at the same thing - are you referring to the errors
appearing on the bonding interfaces? I.e., ~10^(-6) of Rx packets are errors?
Also, how exactly do you classify such errors as overruns?

If you can, please provide `ethtool -S' and `ethtool -I' outputs for
base interfaces. Also, for good measures, please provide an `ethtool -d'
output as well.

Thanks,
Yuval
