From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] Phonet: mark the pipe controller as EXPERIMENTAL
Date: Fri, 08 Oct 2010 14:17:52 -0700 (PDT)
Message-ID: <20101008.141752.02269852.davem@davemloft.net>
References: <1286546523-3340-2-git-send-email-remi@remlab.net>
	<1286546523-3340-3-git-send-email-remi@remlab.net>
	<1286546523-3340-4-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, remi.denis-courmont@nokia.com
To: remi@remlab.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41185
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933067Ab0JHVRb convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 17:17:31 -0400
In-Reply-To: <1286546523-3340-4-git-send-email-remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=E9mi Denis-Courmont <remi@remlab.net>
Date: Fri,  8 Oct 2010 17:02:03 +0300

> From: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>
>=20
> There are a bunch of issues that need to be fixed, including:
>  - GFP_KERNEL allocations from atomic context
>    (and GFP_ATOMIC in process context),
>  - abuse of the setsockopt() call convention,
>  - unprotected/unlocked static variables...
>=20
> IMHO, we will need to alter the userspace ABI when we fix it. So mark
> the configuration option as EXPERIMENTAL for the time being (or shoul=
d
> it be BROKEN instead?).
>=20
> Signed-off-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
