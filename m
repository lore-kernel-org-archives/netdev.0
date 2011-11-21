From: =?UTF-8?Q?Sjur_Br=C3=A6ndeland?= <sjurbren@gmail.com>
Subject: Re: [patch v2] caif: fix endian conversion in cffrml_transmit()
Date: Mon, 21 Nov 2011 22:20:09 +0100
Message-ID: <CAJK669bL51Ct-Q9LxXwFdiaQAnfkx2Um1k0Cutci2z6mdd2THw@mail.gmail.com>
References: <20111121061722.GD7354@elgon.mountain>
	<20111121063356.GH2203@ZenIV.linux.org.uk>
	<20111121195056.GM29436@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f53.google.com ([209.85.216.53]:61455 "EHLO
	mail-qw0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753628Ab1KUV1a convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2011 16:27:30 -0500
In-Reply-To: <20111121195056.GM29436@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The "tmp" variable here is used to store the result of cpu_to_le16()
> so it should be an __le16 instead of an int. =C2=A0We want the high b=
its
> set and the current code works on little endian systems but not on
> big endian systems.
>
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: =C2=A0In v1 I used a u16 instead of an __le16. =C2=A0Also I've ch=
anged the
> name to "data" instead of "tmp".

Thanks Dan, good catch - this would have failed badly on a b_e architec=
ture.

Acked-by: Sjur Br=C3=A6ndeland <sjur.brandeland@stericsson.com>

Regards,
Sjur
