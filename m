From: =?iso-8859-1?Q?Bj=F6rn?= Steinbrink <B.Steinbrink@gmx.de>
Subject: Re: forcedeth: MAC-address reversed on resume from suspend
Date: Mon, 7 Jan 2008 02:46:38 +0100
Message-ID: <20080107014638.GA4170@atjola.homenet>
References: <477BFC71.7090002@coderworld.net> <20080102214843.GA19224@rhlx01.hs-esslingen.de> <20080102234209.GA10831@does.not.exist> <20080104034357.GA2113@atjola.homenet> <b4292e150801061349v3b54ffc0vfed75dbcb83daf9b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Adrian Bunk <bunk@kernel.org>, Andreas Mohr <andi@lisas.de>,
	Richard Jonsson <richie@coderworld.net>,
	linux-kernel@vger.kernel.org, Ayaz Abdulla <aabdulla@nvidia.com>,
	jgarzik@pobox.com, netdev@vger.kernel.org
To: "Adolfo R. Brandes" <arbrandes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:40056 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752890AbYAGBqm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Jan 2008 20:46:42 -0500
Content-Disposition: inline
In-Reply-To: <b4292e150801061349v3b54ffc0vfed75dbcb83daf9b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2008.01.06 19:49:49 -0200, Adolfo R. Brandes wrote:
>  I have this forcedeth MAC address reversal problem when suspending
> on 2 distinct boxes.  I can confirm Steinbrink's patch fixes the
> problem on only one of them:
>=20
> 00:0a.0 Bridge: nVidia Corporation CK804 Ethernet Controller (rev f3)
>=20
>  On the other one the problem persists:
>=20
> 00:14.0 Bridge: nVidia Corporation MCP51 Ethernet Controller (rev a1)

Thanks. Leaves me pretty clueless though. Especially since it worked fo=
r
Richard, who also has a MCP51. In a private mail, you said that you had
hardcoded the mac address in the source. Any chance that you applied th=
e
patch on your modified sources and didn't get it right?

thanks,
Bj=F6rn
