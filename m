From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] rds: Make rds_message_copy_from_user() return 0 on
 success.
Date: Sat, 07 Feb 2015 22:42:21 -0800 (PST)
Message-ID: <20150207.224221.1054400171798732184.davem@davemloft.net>
References: <20150205220734.GC28883@oracle.com>
	<20150205222301.GU29656@ZenIV.linux.org.uk>
	<20150205224143.GD28883@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chien.yen@oracle.com, rds-devel@oss.oracle.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
To: sowmini.varadhan@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150205224143.GD28883@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Thu, 5 Feb 2015 17:41:43 -0500

> Commit 083735f4b01b ("rds: switch rds_message_copy_from_user() to iov_iter")
> breaks rds_message_copy_from_user() semantics on success, and causes it
> to return nbytes copied, when it should return 0.  This commit fixes that bug.
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> changes from v1: incorporate Al.Viro comment. 

Applied.
