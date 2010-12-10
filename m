From: Daniel Baluta <daniel.baluta@gmail.com>
Subject: Re: [PATCH] iproute2: add dynamic index and name hashes
Date: Fri, 10 Dec 2010 18:09:25 +0200
Message-ID: <AANLkTinzMnPiPv7Gv9tC6Tp8c4-dtq9unbpGPcfqE9-=@mail.gmail.com>
References: <1291993164-8793-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Lucian Adrian Grijincu <lucian.grijincu@gmail.com>,
	Vlad Dogaru <ddvlad@rosedu.org>
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62605 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756170Ab0LJQJZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 11:09:25 -0500
Received: by pzk6 with SMTP id 6so138086pzk.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 08:09:25 -0800 (PST)
In-Reply-To: <1291993164-8793-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> + =A0 =A0 =A0 if (!idx_hash) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 idx_hash =3D malloc((1<<hbits) * sizeof=
(struct idxmap_head));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!idx_hash)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (!name_hash) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 name_hash =3D malloc((1<<hbits) * sizeo=
f(struct idxmap_head));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!name_hash)

Can you reach this point with idx_hash non-null? Well, then avoid
memory leaks by freeing it.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
> + =A0 =A0 =A0 }

thanks,
Daniel.
