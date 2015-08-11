From: Manoil Claudiu <claudiu.manoil@freescale.com>
Subject: RE: [PATCH 3/3] gianfar: remove faulty filer optimizer
Date: Tue, 11 Aug 2015 14:00:23 +0000
Message-ID: <BY2PR0301MB0727FA3B33977F2E64975F839C7F0@BY2PR0301MB0727.namprd03.prod.outlook.com>
References: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
 <1439237540-11302-4-git-send-email-moorray3@wp.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jakub Kicinski <kubakici@wp.pl>
To: Jakub Kicinski <moorray3@wp.pl>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0119.outbound.protection.outlook.com ([65.55.169.119]:17652
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964936AbbHKOAZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 10:00:25 -0400
In-Reply-To: <1439237540-11302-4-git-send-email-moorray3@wp.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Jakub Kicinski [mailto:moorray3@wp.pl]
>Sent: Monday, August 10, 2015 11:12 PM
>To: David S. Miller; Manoil Claudiu-B08782
>Cc: netdev@vger.kernel.org; Jakub Kicinski
>Subject: [PATCH 3/3] gianfar: remove faulty filer optimizer
>
>From: Jakub Kicinski <kubakici@wp.pl>
>
>Current filer rule optimization is broken in several ways:
> (1) It destroys rule ordering.
> (2) It performs reads/writes beyond end of allocated tables.
> (3) It breaks badly for rules with more than 2 specifiers
>     (e.g. matching ip, port, tos).
> (4) We observed that the masking rules it generates do not
>     play well with clustering on P2020.  Only first rule
>     of the cluster would ever fire.  Given that optimizer
>     relies heavily on masking this is very hard to fix.
>
>The fact that nobody noticed (1), (3) or (4) makes me think
>that this feature is not very widely used and we should just
>remove it.

I'm not familiar with this filer classification code and its
author is no longer active apparently.   There is not much of a
choice here since this optimization feature is too complex and
poorly documented to be reviewed and validated in a reasonable
time span.
An example, a simple use case showing expected behavior vs.
actual behavior would help.

Thanks,
Claudiu
