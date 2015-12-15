From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add Qualcomm IPC router
Date: Tue, 15 Dec 2015 16:01:14 -0500 (EST)
Message-ID: <20151215.160114.1178824607335349574.davem@davemloft.net>
References: <1449866519-14551-1-git-send-email-bjorn.andersson@sonymobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, srinivas.kandagatla@linaro.org,
	linux-arm-msm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, courtney.cavin@sonymobile.com
To: bjorn.andersson@sonymobile.com
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1449866519-14551-1-git-send-email-bjorn.andersson@sonymobile.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@sonymobile.com>
Date: Fri, 11 Dec 2015 12:41:59 -0800

> +static unsigned int qrtr_local_nid = 1;
> +module_param_named(node_id, qrtr_local_nid, uint, S_IRUGO);
> +MODULE_PARM_DESC(idVendor, "Local Node Identifier");

Module parameters suck.

Allow the user to choose this dynamically.  You have roughtly two choices.

1) Subvert the 'protocol' field passed to ->create() and use that, it is
   being ignored otherwise.

2) Put it into the socket address for bind().
