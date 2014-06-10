From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next PATCH 2] net: ethernet driver: Fujitsu OGMA
Date: Tue, 10 Jun 2014 10:20:49 -0700
Message-ID: <20140610102049.4cad5ca1@nehalam.linuxnetplumber.net>
References: <20140610010803.18695.88446.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Francois Romieu <romieu@fr.zoreil.com>,
	patches@linaro.org
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:56360 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162AbaFJRUx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2014 13:20:53 -0400
Received: by mail-pd0-f179.google.com with SMTP id fp1so6332739pdb.38
        for <netdev@vger.kernel.org>; Tue, 10 Jun 2014 10:20:52 -0700 (PDT)
In-Reply-To: <20140610010803.18695.88446.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2014 09:08:03 +0800
Andy Green <andy.green@linaro.org> wrote:

> +static inline bool skb_is_rx(void *skb)
> +{
> +	struct sk_buff *skb_p = (struct sk_buff *)skb;

Cast of void* to type is unnecessary.
