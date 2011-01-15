From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [patch] caif: checking the wrong variable
Date: Sat, 15 Jan 2011 15:03:31 +0100
Message-ID: <AANLkTimyZQ1BEJ=tPK4LrYWhQaGd+xhYUsVEENibEVoU@mail.gmail.com>
References: <20110115130639.GA2721@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:38063 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885Ab1AOODc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jan 2011 09:03:32 -0500
In-Reply-To: <20110115130639.GA2721@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In the original code we check if (servl =3D=3D NULL) twice. =C2=A0The=
 first time
> should print the message that cfmuxl_remove_uplayer() failed and set
> "ret" correctly, but instead it just returns success. =C2=A0The secon=
d check
> should be checking the value of "ret" instead of "servl".
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Thank you for spotting and correcting this.
Looks good to me (reviewed only)

Acked-by: Sjur Braendeland <sjur.brandeland@stericsson.com>
