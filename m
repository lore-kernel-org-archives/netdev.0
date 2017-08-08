From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Subject: Re: [PATCH net-next] ibmvnic: Add netdev_dbg output for debugging
Date: Tue, 8 Aug 2017 12:27:38 -0500
Message-ID: <d99881d8-d42c-ad94-b685-1038d32a9bae@linux.vnet.ibm.com>
References: <20170807190258.13228.24698.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
 <20170808092714.5f15a1bf@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jallen@linux.vnet.ibm.com,
        tlfalcon@linux.vnet.ibm.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40383 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752221AbdHHR1n (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 13:27:43 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v78HOBwY125601
        for <netdev@vger.kernel.org>; Tue, 8 Aug 2017 13:27:42 -0400
Received: from e12.ny.us.ibm.com (e12.ny.us.ibm.com [129.33.205.202])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2c7hnhg7pt-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 13:27:42 -0400
Received: from localhost
        by e12.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <nfont@linux.vnet.ibm.com>;
        Tue, 8 Aug 2017 13:27:42 -0400
In-Reply-To: <20170808092714.5f15a1bf@xeon-e3>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/2017 11:27 AM, Stephen Hemminger wrote:
> On Mon, 07 Aug 2017 15:02:58 -0400
> Nathan Fontenot <nfont@linux.vnet.ibm.com> wrote:
> 
>> To ease debugging of the ibmvnic driver add a series of netdev_dbg()
>> statements to track driver status, especially during initialization,
>> removal, and resetting of the driver.
>>
>> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
> 
> Maybe use netif_dbg() and the message type stuff.

Oh! I like this even more. This just begs to update all of the message
reporting in the driver though.

Let's scrap this patch. I'll work on a new patchset based on using
the netif_*() infrastructure.

-Nathan

 
