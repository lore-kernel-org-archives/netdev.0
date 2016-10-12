From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 net-next 15/15] smc: proc-fs interface for smc
 connections
Date: Wed, 12 Oct 2016 16:00:27 +0200
Message-ID: <a02646ea-9f36-85fc-f761-fd6ed123051c@linux.vnet.ibm.com>
References: <20160927164156.26184-1-ubraun@linux.vnet.ibm.com>
 <20160927164156.26184-16-ubraun@linux.vnet.ibm.com>
 <20160927.222741.584893707513031004.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        utz.bacher@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:39811 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1755007AbcJLOAe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 10:00:34 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9CDx7mZ039532
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 10:00:33 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 261p5vh80k-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 10:00:33 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 12 Oct 2016 15:00:30 +0100
In-Reply-To: <20160927.222741.584893707513031004.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Dave,

thank you for your feedback. Following your guidance I studied the
inet_diag/tcp_diag kernel code for AF_INET sockets. It could make sense
to create an smc_diag module with an smc_diag_handler to provide
SMC-socket data to userspace. Userspace tools could exploit this by
receiving the SMC-socket data via AF_NETLINK sockets of protocol
NETLINK_SOCK_DIAG.
Please let me know, if this is the right direction.

Regards, Ursula

On 09/28/2016 04:27 AM, David Miller wrote:
> From: Ursula Braun <ubraun@linux.vnet.ibm.com>
> Date: Tue, 27 Sep 2016 18:41:56 +0200
> 
>> Maintain a list of SMC sockets and display important SMC socket
>> information in /proc/net/smc.
>>
>> Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
> 
> Dumping internal tables and information via /procfs is strongly
> deprecated.
> 
> Please use a more modern mechanism (such as netlink) to expose this
> information to the user.
> 
> You'll be most likely to succeed in your submission if you make use of
> or design a generic facility that allows other drivers similar to
> your's to provide this kind of information as well.
> 
> I'm sorry if this is frustrating, but this is a huge piece of
> infrastructure, therefore you can expect lots of pieces to get
> feedback and require changes like this.
> 
> 
