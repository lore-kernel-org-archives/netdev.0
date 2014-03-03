From: David Miller <davem@davemloft.net>
Subject: Re: [patch] qlcnic: dcb: a couple off by one bugs
Date: Mon, 03 Mar 2014 15:38:35 -0500 (EST)
Message-ID: <20140303.153835.1544124603637093354.davem@davemloft.net>
References: <20140301135436.GB23929@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shahed.shaikh@qlogic.com, Dept-HSGLinuxNICDev@qlogic.com,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20140301135436.GB23929@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Sat, 1 Mar 2014 16:54:36 +0300

> The ->tc_cfg[] array has QLC_DCB_MAX_TC (8) elements so the check is
> off by one.  These functions are always called with valid values though
> so it doesn't affect how the code works.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks a lot Dan.
