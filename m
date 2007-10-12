From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/7] [TCP]: No need to re-count fackets_out/sacked_out
 at RTO
Date: Thu, 11 Oct 2007 17:35:06 -0700 (PDT)
Message-ID: <20071011.173506.68150898.davem@davemloft.net>
References: <11921028673528-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028673030-git-send-email-ilpo.jarvinen@helsinki.fi>
	<11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, takano@axe-inc.co.jp
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51171
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753869AbXJLAfD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Oct 2007 20:35:03 -0400
In-Reply-To: <11921028672853-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 11 Oct 2007 14:41:05 +0300

> Both sacked_out and fackets_out are directly known from how
> parameter. Since fackets_out is accurate, there's no need for
> recounting (sacked_out was previously unnecessarily counted
> in the loop anyway).
>=20
> Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>

Applied.
