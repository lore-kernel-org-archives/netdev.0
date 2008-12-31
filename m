From: Russell King <rmk@arm.linux.org.uk>
Subject: Re: 2.6.27.8 (+the idr fix) TCP Ack issue
Date: Wed, 31 Dec 2008 17:10:16 +0000
Message-ID: <20081231171016.GA1901@flint.arm.linux.org.uk>
References: <20081230195858.GA23530@flint.arm.linux.org.uk> <Pine.LNX.4.64.0812311200570.3120@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from caramon.arm.linux.org.uk ([78.32.30.218]:41753 "EHLO
	caramon.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756016AbYLaRKt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Dec 2008 12:10:49 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0812311200570.3120@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 31, 2008 at 12:38:24PM +0200, Ilpo J=E4rvinen wrote:
> If you have the dump still at handy, could you add couple of -v -v fo=
r
> tcpdump. It could be that the peer is using bogus seqnos in the
> duplicate ACK but by default that's not visible for zero sized segs
> (checked in tcp_validate_incoming in the 2.6.28.7 kernel).

Is "seqno" another name for the IP ID field?

--=20
Russell King
