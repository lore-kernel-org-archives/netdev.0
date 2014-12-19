From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next v3] Add support of Cavium Liquidio ethernet
 adapters
Date: Thu, 18 Dec 2014 23:28:33 -0800
Message-ID: <20141218232833.3e640164@urahara>
References: <feba8d6dd1904fc3936864ae332df6d8@CO2PR0701MB744.namprd07.prod.outlook.com>
	<1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:38126 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbaLSH2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2014 02:28:43 -0500
Received: by mail-pa0-f50.google.com with SMTP id bj1so656024pad.37
        for <netdev@vger.kernel.org>; Thu, 18 Dec 2014 23:28:43 -0800 (PST)
In-Reply-To: <1418959519-31681-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 18 Dec 2014 19:25:19 -0800
Raghu Vatsavayi <rvatsavayi@caviumnetworks.com> wrote:

> +void process_noresponse_list(struct octeon_device *oct,
> +			     struct octeon_instr_queue *iq)
> +{
> +	uint32_t get_idx;
> +	struct octeon_soft_command *sc;
> +	struct octeon_instr_ih *ih;

All global function names must start with same prefix, driver may not
always be built as a module. 

In this case oceteon_process_noresponse_list.
