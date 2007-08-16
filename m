From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: skge and sky2 stop working after a few minutes.
Date: Thu, 16 Aug 2007 09:17:13 -0400
Message-ID: <20070816091713.66c1d147@oldman>
References: <loom.20070815T224114-635@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?B?U8OpYmFzdGllbg==?= Judenherc
	<sebastien.judenherc@agecodagis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:49873 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757402AbXHPNQo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Aug 2007 09:16:44 -0400
In-Reply-To: <loom.20070815T224114-635@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 15 Aug 2007 21:20:37 +0000 (UTC)
S=C3=A9bastien Judenherc  <sebastien.judenherc@agecodagis.com> wrote:

> Hello,
> I can see some very strange problem with sky2 and skge interfaces wit=
h 2.6.22,
> and also 2.6.23-rc2/3.
> After 8-9 minutes, the interfaces stop working. ethtool reports that =
the link is
> down and the only way to make the interfaces usable again is
> removing/reinserting the module or running ethtool -r.
> This occurs for both sky2 and skge for two PCs connected to a gigabit=
 switch.
> The other PCs on the same switch continue to work fine (most are 100M=
bit/s). It
> also occurs on a third PC with skge, directly connected to a 100Mbit/=
s interface
> over a cross over cable. I didn't notice the problem with 2.6.19.
>=20

Looks like some noise sensitivity in the PHY. Could you try the vendor =
sk98lin
driver, although all drivers use the same phy settings.
