From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH 1/5] rds: tcp: release the created connection
Date: Mon, 27 Mar 2017 05:17:29 -0400
Message-ID: <20170327091729.GA30457@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
 <1490598390-13812-2-git-send-email-yanjun.zhu@oracle.com>
 <20170327073756.GA21982@oracle.com>
 <58D8C7D9.1070509@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: santosh.shilimkar@oracle.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org, rds-devel@oss.oracle.com,
        junxiao.bi@oracle.com, joe.jin@oracle.com
To: Yanjun Zhu <yanjun.zhu@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49118 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751787AbdC0JSM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Mar 2017 05:18:12 -0400
Content-Disposition: inline
In-Reply-To: <58D8C7D9.1070509@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/27/17 16:05), Yanjun Zhu wrote:
> Sorry. I just made simple test. It seems that it worked well. Would you like
> to show me some test about this patch?
> 

Your patch is a non-trivial bug. Dont do this.

Please read the comments above the "goto rst_nsk" in that function.
Also note the comments above rds_conn_destroy.

Thanks
--Sowmini
