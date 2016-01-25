From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 4.1] [media] media/vivid-osd: fix info leak in ioctl
Date: Mon, 25 Jan 2016 09:18:44 -0800
Message-ID: <20160125171844.GA27264@kroah.com>
References: <1453718538-21691-1-git-send-email-machida.yuki@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Salva =?iso-8859-1?Q?Peir=F3?= <speirofr@gmail.com>,
	Hans Verkuil <hans.verkuil@cisco.com>,
	Mauro Carvalho Chehab <mchehab@osg.samsung.com>
To: Yuki Machida <machida.yuki@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:40298 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933440AbcAYRSq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 12:18:46 -0500
Content-Disposition: inline
In-Reply-To: <1453718538-21691-1-git-send-email-machida.yuki@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 25, 2016 at 07:42:18PM +0900, Yuki Machida wrote:
> commit eda98796aff0d9bf41094b06811f5def3b4c333c upstream.
>=20
> The vivid_fb_ioctl() code fails to initialize the 16 _reserved bytes =
of
> struct fb_vblank after the ->hcount member. Add an explicit
> memset(0) before filling the structure to avoid the info leak.
>=20
> This fixes CVE-2015-7884.
>=20
> Signed-off-by: Salva Peir=F3 <speirofr@gmail.com>
> Signed-off-by: Hans Verkuil <hans.verkuil@cisco.com>
> Signed-off-by: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
> Signed-off-by: Yuki Machida <machida.yuki@jp.fujitsu.com>
> ---
>  drivers/media/platform/vivid/vivid-osd.c | 1 +
>  1 file changed, 1 insertion(+)

<formletter>

This is not the correct way to submit patches for inclusion in the
stable kernel tree.  Please read Documentation/stable_kernel_rules.txt
for how to do this properly.

</formletter>
