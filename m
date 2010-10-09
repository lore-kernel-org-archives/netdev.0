From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] forcedeth: reconfigure multicast packet filter only
 when needed
Date: Sat, 9 Oct 2010 11:32:13 -0700
Message-ID: <20101009113213.62c2f131@nehalam>
References: <20100812115430.2b5d8683@starbug.prg01.itonis.net>
	<AANLkTinbgud9enM1XDQrdZVBtGnTFaUeoEL-D8Z2FmJh@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, aabdulla@nvidia.com, ditto@google.com
To: =?UTF-8?B?SmluZMWZaWNoIE1ha292acSNa2E=?= <makovick@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47881 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756067Ab0JIScR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Oct 2010 14:32:17 -0400
In-Reply-To: <AANLkTinbgud9enM1XDQrdZVBtGnTFaUeoEL-D8Z2FmJh@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 9 Oct 2010 13:26:05 +0200
Jind=C5=99ich Makovi=C4=8Dka <makovick@gmail.com> wrote:

> +
> +	/* current packet filter state */
> +	u32 cur_pff;
> +	u32 cur_addr[2];
> +	u32 cur_mask[2];
>  };

No big deal, but couldn't you just put those temporary variables
on the stack. and reread the current value before stopping.

--=20
