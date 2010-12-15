From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] ixgb: Convert to new vlan model.
Date: Wed, 15 Dec 2010 14:49:42 -0800
Message-ID: <AANLkTikyWHzqU_iLYSfoYCS+oUV2eSzSCTrKzU6S0ehf@mail.gmail.com>
References: <1292298163-30343-1-git-send-email-jesse@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f180.google.com ([209.85.214.180]:42989 "EHLO
	mail-iw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752460Ab0LOWtm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 17:49:42 -0500
Received: by iwn37 with SMTP id 37so2848824iwn.11
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 14:49:42 -0800 (PST)
In-Reply-To: <1292298163-30343-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 13, 2010 at 19:42, Jesse Gross <jesse@nicira.com> wrote:
> This switches the ixgb driver to use the new vlan interfaces.
> In doing this, it completes the work begun in
> ae54496f9e8d40c89e5668205c181dccfa9ecda1 allowing the use of
> hardware vlan insertion without having a vlan group configured.
>
> Signed-off-by: Jesse Gross <jesse@nicira.com>
> CC: Emil Tantilov <emil.s.tantilov@intel.com>
> CC: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> CC: Alex Duyck <alexander.h.duyck@intel.com>
> ---
> =C2=A0drivers/net/ixgb/ixgb.h =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=
=A02 +-
> =C2=A0drivers/net/ixgb/ixgb_ethtool.c | =C2=A0 41 +++++++++++++++++++=
++++++++++
> =C2=A0drivers/net/ixgb/ixgb_main.c =C2=A0 =C2=A0| =C2=A0 54 ++++++++-=
-----------------------------
> =C2=A03 files changed, 54 insertions(+), 43 deletions(-)
>

I have added this patch to my tree for testing and review.  Thanks Jess=
e.

--=20
Cheers,
Jeff
