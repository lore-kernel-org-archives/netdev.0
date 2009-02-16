From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] atl1c:Atheros L1C Gigabit Ethernet driver
Date: Mon, 16 Feb 2009 10:53:09 +0100
Message-ID: <49993785.3090907@gmail.com>
References: <12347653231514-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jcliburn@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jie.yang@atheros.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:17692 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752525AbZBPJxO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Feb 2009 04:53:14 -0500
In-Reply-To: <12347653231514-git-send-email-jie.yang@atheros.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/16/2009 07:22 AM, jie.yang@atheros.com wrote:
> +	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, 0),
> +			pci_resource_len(pdev, 0));

Just in case, is the space cacheable?
