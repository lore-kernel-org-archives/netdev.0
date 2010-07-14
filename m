From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 2/5] qlcnic: disable tx timeout recovery
Date: Tue, 13 Jul 2010 23:09:47 -0700 (PDT)
Message-ID: <20100713.230947.189709998.davem@davemloft.net>
References: <1279086893-22523-1-git-send-email-amit.salecha@qlogic.com>
	<1279086893-22523-3-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39841
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750975Ab0GNGJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 02:09:32 -0400
In-Reply-To: <1279086893-22523-3-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Tue, 13 Jul 2010 22:54:50 -0700

>  
> -		if (adapter->reset_context) {
> +		if (adapter->reset_context &&
> +				auto_fw_reset == AUTO_FW_RESET_ENABLED) {

This new second line is improperly indented.

"auto_fw_reset" should line up with the first character
after the openning "(" on the previous line.
