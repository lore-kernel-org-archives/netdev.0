From: "Li Yang" <leoli@freescale.com>
Subject: Re: [PATCH 6/6] ucc_geth: Remove UGETH_FILTERING dead code
Date: Mon, 22 Dec 2008 19:13:43 +0800
Message-ID: <2a27d3730812220313w5882edb8nf7c2978cd0dcac5f@mail.gmail.com>
References: <20081218182335.GF30682@oksana.dev.rtsoft.ru>
	 <ed82fe3e0812201923s7ff3401i2d12aca4ae9de1e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Anton Vorontsov" <avorontsov@ru.mvista.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	"Andy Fleming" <afleming@freescale.com>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"David Miller" <davem@davemloft.net>
To: "Timur Tabi" <timur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:35813 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752890AbYLVLNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Dec 2008 06:13:44 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1857899rvb.1
        for <netdev@vger.kernel.org>; Mon, 22 Dec 2008 03:13:43 -0800 (PST)
In-Reply-To: <ed82fe3e0812201923s7ff3401i2d12aca4ae9de1e7@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 21, 2008 at 11:23 AM, Timur Tabi <timur@freescale.com> wrote:
> On Thu, Dec 18, 2008 at 12:23 PM, Anton Vorontsov
> <avorontsov@ru.mvista.com> wrote:
>> The code appears to be dead: nobody call these functions, plus build
>> breaks when UGETH_FILTERING is enabled:
>
> I general, I agree with patches like this, but I'd like to hear from
> Leo first why this code was written in the first place before I can
> ack it.

The code was there to test the frame filtering feature which probably
can be used in multicast and VLAN support.  I didn't remove it because
it could be a base for whoever interested to implement a general frame
filtering framework or custom features.  Given the fact that unused
code can easily become broken.  I agree that it can be removed for
now.

Acked-by: Li Yang <leoli@freescale.com>
