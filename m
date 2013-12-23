From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] ibmveth: Fix more little endian issues
Date: Mon, 23 Dec 2013 06:52:09 -0800
Message-ID: <1387810329.22671.66.camel@joe-AO722>
References: <1387762163-39662-1-git-send-email-agraf@suse.de>
	 <20131223173833.0a9a6705@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alexander Graf <agraf@suse.de>, linuxppc-dev@lists.ozlabs.org,
	Ben Herrenschmidt <benh@kernel.crashing.org>,
	Dinar Valeev <dvaleev@suse.com>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0050.hostedemail.com ([216.40.44.50]:38283 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932223Ab3LWOwM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Dec 2013 09:52:12 -0500
In-Reply-To: <20131223173833.0a9a6705@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-23 at 17:38 +1100, Anton Blanchard wrote:
> The hypervisor expects MAC addresses passed in registers to be big
> endian u64.

So maybe use __be64 declarations?

> +static unsigned long ibmveth_encode_mac_addr(char *mac)

static __be64 ibmveth_encode_mac_addr(const char *mac)

?

etc...
