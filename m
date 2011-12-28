From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: detect loss above high_seq in recovery
Date: Wed, 28 Dec 2011 13:07:36 -0500 (EST)
Message-ID: <20111228.130736.79570418506453470.davem@davemloft.net>
References: <1325033182-25905-1-git-send-email-ycheng@google.com>
	<alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, ncardwell@google.com, nanditad@google.com,
	netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56503 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab1L1SHv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Dec 2011 13:07:51 -0500
In-Reply-To: <alpine.DEB.2.00.1112281736480.7752@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Wed, 28 Dec 2011 17:42:06 +0200 (EET)

> I don't think you can remove MIBs as they're userspace visible.

Because of how they are implemented and how applications use them,
this is actually allowed.

All the MIBs are presented first as a series of strings, then as a
series of values.

So applications parse them both to report the statistics, and this do
get coded in a way that they do not need to assume the presence or
particular ordering of these MIBS.

Therefore, such a change is safe.
