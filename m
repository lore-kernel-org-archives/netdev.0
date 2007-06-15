From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH net-2.6] [TCP]: Congestion control API RTT sampling fix
Date: Fri, 15 Jun 2007 07:32:55 -0700
Message-ID: <20070615073255.733f64e3@localhost>
References: <Pine.LNX.4.64.0706151227330.15358@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: "Ilpo =?UTF-8?B?SsOkcnZpbmVuIg==?= <ilpo.jarvinen@helsinki.fi>"@smtp2.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41728 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752260AbXFOOdJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2007 10:33:09 -0400
In-Reply-To: <Pine.LNX.4.64.0706151227330.15358@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 15 Jun 2007 12:30:12 +0300 (EEST)
"Ilpo J=C3=A4rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Commit 164891aadf1721fca4dce473bb0e0998181537c6 broke RTT
> sampling of congestion control modules. Inaccurate timestamps
> could be fed to them without providing any way for them to
> identify such cases. Previously RTT sampler was called only if
> FLAG_RETRANS_DATA_ACKED was not set filtering inaccurate
> timestamps nicely. In addition, the new behavior could give an
> invalid timestamp (zero) to RTT sampler if only skbs with
> TCPCB_RETRANS were ACKed. This solves both problems.
>=20
> Signed-off-by: Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>
>
Yes, let's get this in 2.6.22
