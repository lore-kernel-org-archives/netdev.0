From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 2/6 v2] igb: Check if subordinate VFs are assigned to
 virtual machines
Date: Mon, 17 Oct 2011 08:53:58 -0700
Message-ID: <1318866838.5407.3.camel@Joe-Laptop>
References: <1318854062-3628-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1318854062-3628-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Greg Rose <gregory.v.rose@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Christian Benvenuti <benve@cisco.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Dimitris Michailidis <dm@chelsio.com>,
	Jon Mason <jdmason@kudzu.us>,
	James Smart <james.smart@emulex.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:54818 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751512Ab1JQPx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Oct 2011 11:53:59 -0400
In-Reply-To: <1318854062-3628-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-10-17 at 05:20 -0700, Jeff Kirsher wrote:
> From: Greg Rose <gregory.v.rose@intel.com>

Trivia:

> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
[]
> +	if (old_vfs) {
> +		dev_info(&pdev->dev, "%d pre-allocated VFs found - override "
> +			 "max_vfs setting of %d\n", old_vfs, max_vfs);
[]
> +		dev_err(&pdev->dev, "Unable to allocate memory for VF "
> +			"Data Storage\n");

The dev_err line isn't really necessary.
There is a generic allocation failure dump_stack.
Also, please don't split formats into multiple lines.
