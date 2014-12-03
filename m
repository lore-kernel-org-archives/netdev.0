From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH Iproute2 next v2] ip link: Add ipvlan support to the
 iproute2/ip util
Date: Wed, 3 Dec 2014 09:38:31 -0800
Message-ID: <20141203093831.22022a2b@urahara>
References: <1416794771-11193-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:34990 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751457AbaLCRin convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Dec 2014 12:38:43 -0500
Received: by mail-pd0-f177.google.com with SMTP id ft15so15797807pdb.36
        for <netdev@vger.kernel.org>; Wed, 03 Dec 2014 09:38:43 -0800 (PST)
In-Reply-To: <1416794771-11193-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Nov 2014 18:06:11 -0800
Mahesh Bandewar <maheshb@google.com> wrote:

> Adding basic support to create virtual devices using 'ip'
> utility. Following is the syntax -
>=20
> 	ip link add link <master> <virtual> type ipvlan mode [ l2 | l3 ]
> 	e.g. ip link add link eth0 ipvl0 type ipvlan mode l3
>=20
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =C5=BBenczykowski <maze@google.com>
> Cc: Laurent Chavey <chavey@google.com>
> Cc: Tim Hockin <thockin@google.com>
> Cc: Brandon Philips <brandon.philips@coreos.com>
> Cc: Pavel Emelianov <xemul@parallels.com>

Applied to net-next branch.
