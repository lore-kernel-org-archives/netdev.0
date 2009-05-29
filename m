From: "=?iso-8859-1?q?R=E9mi?= Denis-Courmont"
	<remi.denis-courmont@nokia.com>
Subject: Re: [PATCH] Multicast socket option
Date: Fri, 29 May 2009 09:25:18 +0300
Message-ID: <200905290925.19155.remi.denis-courmont@nokia.com>
References: <4A1EC33E.1080201@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	David Stevens <dlstevens@us.ibm.com>,
	Christoph Lameter <cl@linux.com>,
	"David S. Miller" <davem@davemloft.net>
To: ext Nivedita Singhvi <niv@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.233]:25873 "EHLO
	mgw-mx06.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753878AbZE2GY4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 02:24:56 -0400
In-Reply-To: <4A1EC33E.1080201@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 28 May 2009 20:00:46 ext Nivedita Singhvi wrote:
> After some discussion offline with Christoph Lameter and David Steven=
s
> regarding multicast behaviour in Linux, I'm submitting a slightly
> modified patch from the one Christoph submitted earlier.
>
> This patch provides a new socket option IP_MULTICAST_ALL.
>
> In this case, default behaviour is _unchanged_ from the current
> Linux standard. The socket option is set by default to provide
> original behaviour. Sockets wishing to receive data only from
> multicast groups they join explicitly will need to clear this
> socket option.

You can already achieve this by checking the destination address in the=
=20
SOL_PKTINFO ancilliary data. Sure, it will cause extra context switches=
 to=20
process unwanted packets but it will work with any kernel version.

--=20
R=E9mi Denis-Courmont
Nokia Devices R&D, Maemo Software, Helsinki

