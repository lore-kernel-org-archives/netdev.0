From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: Inactive slaves should keep inactive
 flag's value
Date: Tue, 01 Apr 2014 16:12:21 -0400 (EDT)
Message-ID: <20140401.161221.2203778202011452309.davem@davemloft.net>
References: <1396339327-24899-1-git-send-email-zheng.x.li@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com, andy@greyhouse.net,
	j.vosburgh@gmail.com, linux-kernel@vger.kernel.org,
	joe.jin@oracle.com
To: zheng.x.li@oracle.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1396339327-24899-1-git-send-email-zheng.x.li@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Zheng Li <zheng.x.li@oracle.com>
Date: Tue,  1 Apr 2014 16:02:07 +0800

> -			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP)
> +			if ((bond->params.mode == BOND_MODE_ACTIVEBACKUP || bond_is_lb(bond))

As has been suggested, please use USES_PRIMARY() for this entire
logical test.
