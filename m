From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] ethtool: change spi param on ip4 to l4data
Date: Wed, 01 Jun 2011 22:59:42 +0100
Message-ID: <1306965582.2758.42.camel@bwh-desktop>
References: <32899.80.254.147.148.1305618034.squirrel@webmail.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, sebastian.poehn@belden.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Santwona Behera <santwona.behera@sun.com>
To: s.poehn@stud.hs-esslingen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:49938 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754074Ab1FAV7p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2011 17:59:45 -0400
In-Reply-To: <32899.80.254.147.148.1305618034.squirrel@webmail.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-05-17 at 09:40 +0200, Sebastian P=C3=B6hn wrote:
> It is confusing for users if ip4 has a spi field, which results in
> l4_4_bytes filtering. Add a new option and remove spi from ip4.
[...]

There are supposed to have multiple aliases for setting the l4_4_bytes
field, depending on the layer-4 protocol: 'spi', 'src-port', 'dst-port'=
,
and potentially others.  These could be used when the hardware doesn't
have specific support for the L4 protocol but can filter on the first 4
bytes of its header.

You could change the manual page to explain the assumptions behind thes=
e
options.  You could also add this generic option (l4data, or possibly
options for each of the 4 bytes).  But don't remove the existing ones.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

