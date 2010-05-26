From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [patch] caif: unlock on error path in cfserl_receive()
Date: Wed, 26 May 2010 20:18:36 +0200
Message-ID: <AANLkTimYIjrnOwzSyALY42fhNojwh1zawaFMUVC1ml6Y@mail.gmail.com>
References: <20100526151648.GA15439@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sjur Braendeland <sjur.brandeland@stericsson.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:62003 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755109Ab0EZSSj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 14:18:39 -0400
In-Reply-To: <20100526151648.GA15439@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan.

Dan Carpenter <error27@gmail.com> wrote:
> There was an spin_unlock missing on the error path. =C2=A0The spin_lo=
ck was
> tucked in with the declarations so it was hard to spot. =C2=A0I added=
 a new
> line.
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
Acked-by: Sjur Braendeland

Well spotted! Thanks for reviewing and fixing this.

Regards
Sjur
