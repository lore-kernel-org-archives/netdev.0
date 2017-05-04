From: Gavin Shan <gwshan@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 net-next 00/10] net/ncsi: Add debugging functionality
Date: Thu, 4 May 2017 10:09:28 +1000
Message-ID: <20170504000928.GC11287@gwshan>
References: <1493786681-27468-1-git-send-email-gwshan@linux.vnet.ibm.com>
 <20170503125802.GG8029@lunn.ch>
Reply-To: Gavin Shan <gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org,
        joe@perches.com, kubakici@wp.pl, f.fainelli@gmail.com,
        davem@davemloft.net
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:57524 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751366AbdEDAKb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 20:10:31 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4408fJ4107631
        for <netdev@vger.kernel.org>; Wed, 3 May 2017 20:10:30 -0400
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2a7cytjfyb-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 20:10:30 -0400
Received: from localhost
        by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gwshan@linux.vnet.ibm.com>;
        Thu, 4 May 2017 10:10:27 +1000
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
        by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v440AH2W5767534
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:10:25 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
        by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v4409rGp024661
        for <netdev@vger.kernel.org>; Thu, 4 May 2017 10:09:53 +1000
Content-Disposition: inline
In-Reply-To: <20170503125802.GG8029@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 03, 2017 at 02:58:02PM +0200, Andrew Lunn wrote:
>On Wed, May 03, 2017 at 02:44:31PM +1000, Gavin Shan wrote:
>> This series supports NCSI debugging infrastructure by adding several
>> ethtool commands and one debugfs file. It was inspired by the reported
>> issues: No available package and channel are probed successfully.
>> Obviously, we don't have a debugging infrastructure for NCSI stack yet.
>> 
>> The first 3 patches, fixing some issues, aren't relevant to the
>> subject. 
>
>...
>
>> PATCH[9,10] fix two issues found by the debugging functionality.
>
>Hi Gavin
>
>If they are real fixes, you should submit them separately. Please
>include Fixes: tags, and indicate if they need to be included in
>-stable.
>
>David will probably accept fixes while the merge window is closed.
>
>	Andrew
>

Andrew, thanks a lot for the good tip. Yeah, I agree and will follow
in next respin. I think the patches fixing issues should be rebased
to "net" and reposted?

git://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git

Cheers,
Gavin
