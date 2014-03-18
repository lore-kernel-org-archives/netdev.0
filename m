From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH v3 2/2] net: cdc_ncm: respect operator preferred MTU reported by MBIM
Date: Tue, 18 Mar 2014 09:33:40 +0100
Message-ID: <871txzlxcr.fsf@nemi.mork.no>
References: <1395115145-31821-1-git-send-email-benchan@chromium.org>
	<1395115145-31821-2-git-send-email-benchan@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, Oliver Neukum <oliver@neukum.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Greg Suarez <gsuarez@smithmicro.com>
To: Ben Chan <benchan@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1395115145-31821-2-git-send-email-benchan@chromium.org> (Ben
	Chan's message of "Mon, 17 Mar 2014 20:59:05 -0700")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Chan <benchan@chromium.org> writes:

> According to "Universal Serial Bus Communications Class Subclass
> Specification for Mobile Broadband Interface Model, Revision 1.0,
> Errata-1" published by USB-IF, the wMTU field of the MBIM extended
> functional descriptor indicates the operator preferred MTU for IP dat=
a
> streams.
>
> This patch modifies cdc_ncm_setup to ensure that the MTU value set on
> the usbnet device does not exceed the operator preferred MTU indicate=
d
> by wMTU if the MBIM device exposes a MBIM extended functional
> descriptor.
>
> Signed-off-by: Ben Chan <benchan@chromium.org>
> ---
> Patch v3 (which is same as v2) adds the le16_to_cpu conversion on
> ctx->mbim_extended_desc->wMTU as pointed out and suggested by
> 'Bj=C3=B8rn Mork <bjorn@mork.no>'.

Looks good to me FWIW.

I was worried that I might have created a merge conflict here by postin=
g
the unrelated cdc_ncm fix, touching the same function.  But we're in
luck: That fix and your patch applies cleanly on top of each other in
any order.


Bj=C3=B8rn
