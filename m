From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
Subject: Re: [PATCH net v3] ibmveth: set correct gso_size and gso_type
Date: Tue, 13 Dec 2016 09:49:16 -0600
Message-ID: <2a81f718-bc6c-e3a8-9b65-764740e7052b@linux.vnet.ibm.com>
References: <1481333480-10827-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <1481395188-9137-1-git-send-email-tlfalcon@linux.vnet.ibm.com>
 <20161210.155647.1988856288960520451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brking@linux.vnet.ibm.com,
        marcelo.leitner@gmail.com, pradeeps@linux.vnet.ibm.com,
        jmaxwell37@gmail.com, zdai@us.ibm.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:59922 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S933192AbcLMPtX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 10:49:23 -0500
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBDFmcCa093702
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 10:49:23 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27afv7cs3h-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 10:49:22 -0500
Received: from localhost
        by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <tlfalcon@linux.vnet.ibm.com>;
        Tue, 13 Dec 2016 08:49:21 -0700
In-Reply-To: <20161210.155647.1988856288960520451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/10/2016 02:56 PM, David Miller wrote:
> From: Thomas Falcon <tlfalcon@linux.vnet.ibm.com>
> Date: Sat, 10 Dec 2016 12:39:48 -0600
>
>> v3: include a check for non-zero mss when calculating gso_segs
>>
>> v2: calculate gso_segs after Eric Dumazet's comments on the earlier patch
>>     and make sure everyone is included on CC
> I already applied v1 which made it all the way even to Linus's
> tree.  So you'll have to send me relative fixups if there are
> things to fix or change since v1.
>
> You must always generate patches against the current 'net' tree.
>
Sorry about that.  Thank you for applying it on short notice.  I agree that using the TCP checksum field is not ideal, but it was a compromise with the VIOS team.  Hopefully, there will be a better way in the future.

Thanks again,

Tom 
