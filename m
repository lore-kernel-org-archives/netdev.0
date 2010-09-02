From: Chris Snook <chris.snook@gmail.com>
Subject: Re: [PATCH] atlx: make version strings const (trivial)
Date: Thu, 2 Sep 2010 18:24:11 -0400
Message-ID: <AANLkTim5k6pW_XO9eZMMcungCkk5s9LXiqzOemDov3-k@mail.gmail.com>
References: <20100902143438.26ec0ef1@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jcliburn@gmail.com, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:55574 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754673Ab0IBWYc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Sep 2010 18:24:32 -0400
Received: by qwh6 with SMTP id 6so1033483qwh.19
        for <netdev@vger.kernel.org>; Thu, 02 Sep 2010 15:24:31 -0700 (PDT)
In-Reply-To: <20100902143438.26ec0ef1@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 2, 2010 at 5:34 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>
> --- a/drivers/net/atlx/atl2.c =A0 2010-09-02 10:51:39.529679405 -0700
> +++ b/drivers/net/atlx/atl2.c =A0 2010-09-02 10:52:23.904667707 -0700
> @@ -51,10 +51,10 @@
>
> =A0#define ATL2_DRV_VERSION "2.2.3"
>
> -static char atl2_driver_name[] =3D "atl2";
> +static const char atl2_driver_name[] =3D "atl2";
> =A0static const char atl2_driver_string[] =3D "Atheros(R) L2 Ethernet=
 Driver";
> -static char atl2_copyright[] =3D "Copyright (c) 2007 Atheros Corpora=
tion.";
> -static char atl2_driver_version[] =3D ATL2_DRV_VERSION;
> +static const char atl2_copyright[] =3D "Copyright (c) 2007 Atheros C=
orporation.";
> +static const char atl2_driver_version[] =3D ATL2_DRV_VERSION;
>
> =A0MODULE_AUTHOR("Atheros Corporation <xiong.huang@atheros.com>, Chri=
s Snook <csnook@redhat.com>");
> =A0MODULE_DESCRIPTION("Atheros Fast Ethernet Network Driver");
>

Acked-by: Chris Snook <chris.snook@gmail.com>
