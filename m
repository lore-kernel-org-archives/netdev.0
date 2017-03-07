From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net 0/3] rds: tcp: fix various rds-tcp issues during netns
 create/delete sequences
Date: Mon, 6 Mar 2017 17:04:38 -0800
Message-ID: <125d878b-ac8d-dcfd-d1ff-1b1a84cff5a5@oracle.com>
References: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: syzkaller@googlegroups.com, rds-devel@oss.oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>, dvyukov@google.com,
        davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1050.oracle.com ([156.151.31.82]:43005 "EHLO
        userp1050.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754144AbdCGElb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 23:41:31 -0500
Received: from userp1040.oracle.com (userp1040.oracle.com [156.151.31.81])
        by userp1050.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id v2716QuL004869
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
        for <netdev@vger.kernel.org>; Tue, 7 Mar 2017 01:06:27 GMT
In-Reply-To: <cover.1488645926.git.sowmini.varadhan@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/4/17 8:57 AM, Sowmini Varadhan wrote:
> Dmitry Vyukov reported some syszkaller panics during netns deletion.
>
> While I have not been able to reproduce those exact panics, my attempts
> to do so uncovered a few other problems, which are fixed patch 2 and
> patch 3 of this patch series. In addition, as mentioned in,
>  https://www.spinics.net/lists/netdev/msg422997.html
> code-inspection points that the rds_connection needs to take an explicit
> refcnt on the struct net so that it is held down until all cleanup is
> completed for netns removal, and this is fixed by patch1.
>
Hopefully Dmitry can try the series and see if it fixes the issue(s).
The fixes looks good to me.

FWIW, Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
