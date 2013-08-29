From: David Miller <davem@davemloft.net>
Subject: Re: [patch -next] qlcnic: underflow in
 qlcnic_validate_max_tx_rings()
Date: Thu, 29 Aug 2013 01:24:46 -0400 (EDT)
Message-ID: <20130829.012446.182167937298557296.davem@davemloft.net>
References: <20130827011622.GB17061@elgon.mountain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: himanshu.madhani@qlogic.com, rajesh.borundia@qlogic.com,
	shahed.shaikh@qlogic.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, sucheta.chakraborty@qlogic.com,
	linux-driver@qlogic.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20130827011622.GB17061@elgon.mountain>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 27 Aug 2013 04:16:22 +0300

> This function checks the upper bound but it doesn't check for negative
> numbers:
> 
> 	if (txq > QLCNIC_MAX_TX_RINGS) {
> 
> I've solved this by making "txq" a u32 type.  I chose that because
> ->tx_count in the ethtool_channels struct is a __u32.
> 
> This bug was added in aa4a1f7df7 ('qlcnic: Enable Tx queue changes using
> ethtool for 82xx Series adapter.').
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
