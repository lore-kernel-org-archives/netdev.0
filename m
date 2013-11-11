From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: spurious ip forwarding inside namespaces
Date: Mon, 11 Nov 2013 00:01:11 -1000
Message-ID: <CAHo-OowLFvH_cR-sJN2ft_2E4ASCcWTBQCOp__3CSwU72EqSeg@mail.gmail.com>
References: <CAMEtUuwKD76xEhysPbLum5wDYyJaX5p0JpdBQUcdHged40eHdg@mail.gmail.com>
	<CAHo-Oow6h1LRNw5DMb4+6bdwy31WGOTNokKe=C5cj40dDhTyQQ@mail.gmail.com>
	<CAMEtUuz70qyDgB1-EH9xPK71PagxwHFVCzmrnwC2uWum_gxxFg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux NetDev <netdev@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f44.google.com ([209.85.212.44]:64810 "EHLO
	mail-vb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753071Ab3KKKBL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 05:01:11 -0500
Received: by mail-vb0-f44.google.com with SMTP id 11so3121855vbe.3
        for <netdev@vger.kernel.org>; Mon, 11 Nov 2013 02:01:11 -0800 (PST)
In-Reply-To: <CAMEtUuz70qyDgB1-EH9xPK71PagxwHFVCzmrnwC2uWum_gxxFg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't really understand what he was trying to fix (seemed like a
userspace misconfiguration issue to me=E2=80=A6), but it seems pretty c=
lear
that this is not the right way to go about it.
Ignoring destination mac address is not the right way to go about doing=
 things.
