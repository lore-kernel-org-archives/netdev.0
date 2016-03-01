From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [net-next][PATCH v2 00/13] RDS: Major clean-up with couple of new
 features for 4.6
Date: Tue, 1 Mar 2016 15:09:40 -0800
Message-ID: <56D62134.3000804@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
 <20160301.173308.391621325255066441.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:30171 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbcCAXJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 18:09:47 -0500
In-Reply-To: <20160301.173308.391621325255066441.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/1/2016 2:33 PM, David Miller wrote:
>
> When I try to apply this series, it (strangely) fails on the first patch with:
>
Strange indeed since patches and the tree is against net-next.

> Applying: RDS: Drop stale iWARP RDMA transport
> error: removal patch leaves file contents
This patch has file removals and looks like git am/apply won't
work when patch is formatted with "-D". Its good
for review but didn't realize it will create problem for
apply. Sorry for that but I didn't know this issue.

git merge or pull seems to work though when tried from branch
directly.

>
> Please sort this out and respin, thanks.
>
OK. Will send the same series again just with first
patch generated without -D option. Thanks !!

Regards,
Santosh
