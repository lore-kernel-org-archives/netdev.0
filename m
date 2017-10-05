From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: Re: [PATCH v1] s390/qeth: use kstrtobool() in
 qeth_bridgeport_hostnotification_store()
Date: Thu, 5 Oct 2017 10:22:43 +0200
Message-ID: <5c0ddbd0-0843-03e3-bceb-5422e2789623@linux.vnet.ibm.com>
References: <20171004133851.18595-1-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        linux-s390@vger.kernel.org, David Miller <davem@davemloft.net>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:42412 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751330AbdJEIXD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 04:23:03 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v958MeeY049741
        for <netdev@vger.kernel.org>; Thu, 5 Oct 2017 04:23:02 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2ddeubxt17-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 05 Oct 2017 04:23:01 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Thu, 5 Oct 2017 09:22:46 +0100
In-Reply-To: <20171004133851.18595-1-andriy.shevchenko@linux.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/04/2017 03:38 PM, Andy Shevchenko wrote:
> The sysfs enabled value is a boolean, so kstrtobool() is a better fit
> for parsing the input string since it does the range checking for us.
> 
> Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> ---

Thanks Andy, queued up for our next upstream submission.
