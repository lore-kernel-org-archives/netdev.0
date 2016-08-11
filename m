From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCHv3 net-next 1/2] cxgb4: Add control net_device for
 configuring PCIe VF
Date: Thu, 11 Aug 2016 10:22:03 +0000
Message-ID: <CO2PR11MB0088B7B0FC2202287F8BD2FE971E0@CO2PR11MB0088.namprd11.prod.outlook.com>
References: <1470887687-27155-1-git-send-email-hariprasad@chelsio.com>
 <1470887687-27155-2-git-send-email-hariprasad@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: David Miller <davem@davemloft.net>,
	"leedom@chelsio.com" <leedom@chelsio.com>,
	"nirranjan@chelsio.com" <nirranjan@chelsio.com>
To: Hariprasad Shenai <hariprasad@chelsio.com>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0106.outbound.protection.outlook.com ([104.47.40.106]:52512
	"EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932173AbcHKKh3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2016 06:37:29 -0400
In-Reply-To: <1470887687-27155-2-git-send-email-hariprasad@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	adapter->mbox_log = kzalloc(sizeof(*adapter->mbox_log) +
> +				    (sizeof(struct mbox_cmd) *
> +				     T4_OS_LOG_MBOX_CMDS),
> +				    GFP_KERNEL);
> +	pi = netdev_priv(netdev);
You probably want to check mbox_log allocation.
