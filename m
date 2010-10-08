From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] Phonet: cleanup pipe enable socket option
Date: Fri, 08 Oct 2010 14:17:46 -0700 (PDT)
Message-ID: <20101008.141746.233705255.davem@davemloft.net>
References: <1286546523-3340-1-git-send-email-remi@remlab.net>
	<1286546523-3340-2-git-send-email-remi@remlab.net>
	<1286546523-3340-3-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com,
	kumar.sanghvi@stericsson.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41178
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933065Ab0JHVRY convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 17:17:24 -0400
In-Reply-To: <1286546523-3340-3-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Fri,  8 Oct 2010 17:02:02 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> The current code works like this:
 ...
> ...which does not follow the usual socket option pattern. This patch
> merges all three "options" into a single gettable&settable option,
> before Linux 2.6.37 gets out:
 ...
> This also fixes the error code from EFAULT to ENOTCONN.
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
> Cc: Kumar Sanghvi <kumar.sanghvi@stericsson.com>

Applied.
