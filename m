From: Benjamin Herrenschmidt <benh@au1.ibm.com>
Subject: Re: genphy_read_status() vs. 1000bT Pause capability
Date: Tue, 28 Mar 2017 13:55:34 +1100
Message-ID: <1490669734.3177.100.camel@au1.ibm.com>
References: <1490662190.3177.91.camel@kernel.crashing.org>
         <20170328010940.GG25549@lunn.ch>
         <1490668137.3177.98.camel@kernel.crashing.org>
Reply-To: benh@au1.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:35299 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753849AbdC1C4i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 22:56:38 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v2S2rTEK039862
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 22:56:36 -0400
Received: from e23smtp09.au.ibm.com (e23smtp09.au.ibm.com [202.81.31.142])
        by mx0b-001b2d01.pphosted.com with ESMTP id 29feuk9uc2-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 27 Mar 2017 22:56:36 -0400
Received: from localhost
        by e23smtp09.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <benh@au1.ibm.com>;
        Tue, 28 Mar 2017 12:56:33 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
        by d23relay06.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v2S2uN6S49479804
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 13:56:31 +1100
Received: from d23av03.au.ibm.com (localhost [127.0.0.1])
        by d23av03.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v2S2tug3024368
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 13:55:56 +1100
In-Reply-To: <1490668137.3177.98.camel@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-03-28 at 13:28 +1100, Benjamin Herrenschmidt wrote:
> 
> > Hi Ben
> > 
> > It is worth reading Documentation/networking/phy.txt
> > 
> > The MAC should set SUPPORTED_Pause and SUPPORTED_Asym_Pause if the MAC
> > supports these features. The PHY will then negotiate them.
> 
Haha ! The OpenBMC kernel is still at 4.7 which was still saying you
should only clear bits in there :-) I think that's what I initially
read.

Thanks for the pointer.

Doesn't fix my other problem with Pause in 1000bT land. Do you know if
that way of reflecting the pause capability by hijacking the old
LPA bits is widely implemented enough that we should put it in
genphy_read_status() ?

Cheers,
Ben.
