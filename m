From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Fix IP timestamp option (IPOPT_TS_PRESPEC) handling in
 ip_options_echo()
Date: Sun, 27 Mar 2011 18:32:11 -0700 (PDT)
Message-ID: <20110327.183211.232760520.davem@davemloft.net>
References: <1300988662-13204-1-git-send-email-jluebbe@debian.org>
	<20110324.162005.71589730.davem@davemloft.net>
	<1301033472.3890.181.camel@mordor>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: jluebbe@debian.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753056Ab1C1Bcu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Mar 2011 21:32:50 -0400
In-Reply-To: <1301033472.3890.181.camel@mordor>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jan L=FCbbe <jluebbe@debian.org>
Date: Fri, 25 Mar 2011 07:11:12 +0100

> The encoding of soffset is a bit unusual, in that the option is 'full=
'
> when soffset =3D optlen + 1. We need to keep advancing soffset by 8
> because that's really the amount of data per entry.

Ok, this code is officially terrible :-)

Thanks for explaining things, I've applied your patch, thanks.
