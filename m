From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next 09/10] net/mlx4_en: Manage flow steering rules with ethtool
Date: Mon, 2 Jul 2012 11:19:50 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6F70@saturn3.aculab.com>
References: <1341172352.8675.5.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"Or Gerlitz" <ogerlitz@mellanox.com>, <davem@davemloft.net>,
	<roland@kernel.org>, <yevgenyp@mellanox.com>, <oren@mellanox.com>,
	<netdev@vger.kernel.org>, "Hadar Hen Zion" <hadarh@mellanox.co.il>
To: "Joe Perches" <joe@perches.com>,
	"Andreas Schwab" <schwab@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:40412 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S932985Ab2GBKVO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jul 2012 06:21:14 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 12658-09 for <netdev@vger.kernel.org>;
 Mon,  2 Jul 2012 11:21:11 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1341172352.8675.5.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > Or write it as (!field || !(typeof(field))~field) which more closely
> > resembles what the macro name expresses.
> 
> Better still, or maybe:
> 
> 	field == 0 || field == (typeof field)~0

Which doesn't work when sizeof(field) > sizeof(int).
Needs another cast.

	field == 0 || field == (typeof field)~(typeof field)0

	David
