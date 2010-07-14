From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 5/5] qlcnic: restore NPAR config data after
 recovery
Date: Tue, 13 Jul 2010 23:10:53 -0700 (PDT)
Message-ID: <20100713.231053.112610215.davem@davemloft.net>
References: <1279086893-22523-1-git-send-email-amit.salecha@qlogic.com>
	<1279086893-22523-6-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com, rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39845
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751275Ab0GNGKi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 02:10:38 -0400
In-Reply-To: <1279086893-22523-6-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Tue, 13 Jul 2010 22:54:53 -0700

> +	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED)
> +				|| !adapter->need_fw_reset)
> +		return 0;

There is more improper indentation of a conditional here.
It should read:

	if (!(adapter->flags & QLCNIC_ESWITCH_ENABLED) ||
	    !adapter->need_fw_reset)
