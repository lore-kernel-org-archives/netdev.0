From: Vince Bridgers <vbridgers2013@gmail.com>
Subject: Re: [PATCH net-next 1/7] altera: Remove casts of pointer to same type
Date: Mon, 24 Mar 2014 18:36:38 -0500
Message-ID: <CAOwfj2PYHm5Buj-4Z0yP1EMJ-hnVcrVX38spqaFQJYYZAu1RAg@mail.gmail.com>
References: <cover.1395692043.git.joe@perches.com>
	<b3437e88a3d02c3ee8b9378b5801471a38cf24c5.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nios2-dev@lists.rocketboards.org, linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f47.google.com ([74.125.82.47]:43991 "EHLO
	mail-wg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750972AbaCXXgj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 19:36:39 -0400
In-Reply-To: <b3437e88a3d02c3ee8b9378b5801471a38cf24c5.1395692043.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Joe, thanks for the patch.

On Mon, Mar 24, 2014 at 3:15 PM, Joe Perches <joe@perches.com> wrote:
> Casting a pointer to a pointer of the same type is pointless,
> so remove these unnecessary casts.
>
> Done via coccinelle script:
>
> $ cat typecast_2.cocci
> @@
> type T;
> T *foo;
> @@
>
> -       (T *)foo
> +       foo
>
> Signed-off-by: Joe Perches <joe@perches.com>
> ---

Acked-by: Vince Bridgers <vbridgers2013@gmail.com>

All the best,

Vince
