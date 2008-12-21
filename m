From: "Timur Tabi" <timur@freescale.com>
Subject: Re: [PATCH 6/6] ucc_geth: Remove UGETH_FILTERING dead code
Date: Sat, 20 Dec 2008 21:23:06 -0600
Message-ID: <ed82fe3e0812201923s7ff3401i2d12aca4ae9de1e7@mail.gmail.com>
References: <20081218182335.GF30682@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>,
	"Li Yang" <leoli@freescale.com>,
	"Andy Fleming" <afleming@freescale.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: "Anton Vorontsov" <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:18167 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597AbYLUDXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Dec 2008 22:23:07 -0500
Received: by an-out-0708.google.com with SMTP id d40so536987and.1
        for <netdev@vger.kernel.org>; Sat, 20 Dec 2008 19:23:06 -0800 (PST)
In-Reply-To: <20081218182335.GF30682@oksana.dev.rtsoft.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 18, 2008 at 12:23 PM, Anton Vorontsov
<avorontsov@ru.mvista.com> wrote:
> The code appears to be dead: nobody call these functions, plus build
> breaks when UGETH_FILTERING is enabled:

I general, I agree with patches like this, but I'd like to hear from
Leo first why this code was written in the first place before I can
ack it.

-- 
Timur Tabi
Linux kernel developer at Freescale
