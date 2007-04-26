From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: Unexcepted latency (order of 100-200 ms) with TCP (packet receive)
Date: Thu, 26 Apr 2007 12:16:41 -0400
Message-ID: <4630D069.30605@redhat.com>
References: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39573 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031330AbXDZQQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 12:16:48 -0400
In-Reply-To: <Pine.LNX.4.64.0704241518370.28337@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> ...I'm unsure how to continue the investigation from this point onwar=
d=20
> and asking for ideas/suggestions or how to rule out more possibilitie=
s...=20
> Or is there some knob which I don't know of that should be toggled or=
=20
> something, is 2.6 network stack expected to behave this way?
>=20

Try a different network adapter.

Try turning off hardware TSO offload:
  ethtool -K ethX tso off

