From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] [TCP]: Move clearing of the prior_ssthresh due to
 ECE earlier
Date: Fri, 02 Mar 2007 13:28:43 -0800 (PST)
Message-ID: <20070302.132843.118950493.davem@davemloft.net>
References: <Pine.LNX.4.64.0703011948330.19465@kivilampi-30.cs.helsinki.fi>
	<Pine.LNX.4.64.0703012220300.25330@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44564
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S965667AbXCBV2n convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 16:28:43 -0500
In-Reply-To: <Pine.LNX.4.64.0703012220300.25330@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 1 Mar 2007 22:26:57 +0200 (EET)

> I think that doing it in the response is better that this approach,
> since it knows that the ssthresh has been halved already within that
> round-trip, so there is no need to do that again... I'll submit the
> patch tomorrow... With this prior_ssthresh clearing move alone, the=20
> ssthresh ends up being halved twice if I tought it right (first in=20
> tcp_enter_frto and then again in tcp_enter_cwr that is called from=20
> fastretrans_alert)... So please, drop this patch.

Ok.
