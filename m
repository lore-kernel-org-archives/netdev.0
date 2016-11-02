From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] xen-netfront: cast grant table reference first to
 type int
Date: Wed, 02 Nov 2016 15:33:52 -0400 (EDT)
Message-ID: <20161102.153352.177155711824743808.davem@davemloft.net>
References: <1478048673-26284-1-git-send-email-dongli.zhang@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        xen-devel@lists.xenproject.org
To: dongli.zhang@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478048673-26284-1-git-send-email-dongli.zhang@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dongli Zhang <dongli.zhang@oracle.com>
Date: Wed,  2 Nov 2016 09:04:33 +0800

> IS_ERR_VALUE() in commit 87557efc27f6a50140fb20df06a917f368ce3c66
> ("xen-netfront: do not cast grant table reference to signed short") would
> not return true for error code unless we cast ref first to type int.
> 
> Signed-off-by: Dongli Zhang <dongli.zhang@oracle.com>

Applied.
