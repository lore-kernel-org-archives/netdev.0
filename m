From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Tue, 27 Oct 2009 17:56:11 +0100
Message-ID: <4AE7262B.1060703@gmail.com>
References: <4AE72079.4030504@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	shemminger@vyatta.com, ilpo.jarvinen@helsinki.fi,
	davem@davemloft.net
To: Andreas Petlund <apetlund@simula.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756208AbZJ0Q5R@vger.kernel.org>
In-Reply-To: <4AE72079.4030504@simula.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andreas Petlund a =E9crit :
> This patch will make TCP use only linear timeouts if the stream is th=
in. This will help to avoid the very high latencies that thin stream su=
ffer because of exponential backoff. This mechanism is only active if e=
nabled by iocontrol or syscontrol and the stream is identified as thin.
>=20

Wont this reduce the session timeout to something very small, ie 15 ret=
ransmits, way under the minute ?
