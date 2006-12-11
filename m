From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] MACB: Use struct delayed_work instead of struct work_struct
Date: Mon, 11 Dec 2006 09:32:23 -0500
Message-ID: <457D6BF7.6030707@pobox.com>
References: <20061208143735.7050553a@dhcp-252-105.norway.atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Patrice Vilchez <patrice.vilchez@rfo.atmel.com>,
	Andrew Victor <andrew@sanpeople.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46182 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935738AbWLKOc2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 09:32:28 -0500
To: Haavard Skinnemoen <hskinnemoen@atmel.com>
In-Reply-To: <20061208143735.7050553a@dhcp-252-105.norway.atmel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Haavard Skinnemoen wrote:
> The macb driver calls schedule_delayed_work() and friends, so we need
> to use a struct delayed_work along with it. The conversion was
> explained by David Howells on lkml Dec 5 2006:
> 
> http://lkml.org/lkml/2006/12/5/269
> 
> Signed-off-by: Haavard Skinnemoen <hskinnemoen@atmel.com>

applied this, and the raw register access patch


