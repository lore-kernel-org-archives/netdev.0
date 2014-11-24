From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2] Add support of Cavium Liquidio ethernet adapters
Date: Mon, 24 Nov 2014 21:52:09 +0100
Message-ID: <54739A79.8000802@redhat.com>
References: <1416799190-23789-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37258 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750824AbaKXUxR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Nov 2014 15:53:17 -0500
In-Reply-To: <1416799190-23789-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/24/2014 04:19 AM, Raghu Vatsavayi wrote:
> Following patch adds support for Cavium Liquidio ethernet adapter.
> LiquidIO adapters are pci express based 10Gig server adapters.
>
> Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
> Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
> Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
> Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>

Please implement BQL in your 10G driver.

Additionally, you might want to consider xmit_more on top of BQL.

If you don't know what BQL is, have a look at the intro here:

   http://lwn.net/Articles/454390/
