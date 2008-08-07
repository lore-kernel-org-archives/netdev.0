From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: SO_REUSEPORT?
Date: Thu, 7 Aug 2008 20:09:34 +0300
Message-ID: <200808072009.34891.rdenis@simphalempin.com>
References: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "Tom Herbert" <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:49619 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752269AbYHGRJh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 13:09:37 -0400
In-Reply-To: <65634d660808070957j12e1f93rfb577efabc771c9a@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 7 ao=FBt 2008 19:57:15 Tom Herbert, vous avez =E9crit=A0:
> Hello,
>
> We are looking at ways to scale TCP listeners.  I think we like is th=
e
> ability to listen on a port from multiple threads (sockets bound to
> same port,  INADDR_ANY, and no interface binding) , which is what
> SO_REUSEPORT would seem to allow.  Has this ever been implemented for
> Linux or is there a good reason not to have it?

On Linux, SO_REUSEADDR provide most of what SO_REUSEPORT provides on BS=
D.

In any case, there is absolutely no point in creating multiple TCP list=
eners.=20
Multiple threads can accept() on the same listener - at the same time.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
