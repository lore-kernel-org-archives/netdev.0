From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net] mlx4_en: set number of rx rings used by RSS using ethtool
Date: Tue, 17 Jan 2012 17:22:18 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF4B@saturn3.aculab.com>
References: <20120117.121841.1486682892503842786.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <amirv@mellanox.co.il>
To: "David Miller" <davem@davemloft.net>, <yevgenyp@mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:60623 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750725Ab2AQRWV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 12:22:21 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18227-07 for <netdev@vger.kernel.org>;
 Tue, 17 Jan 2012 17:22:17 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <20120117.121841.1486682892503842786.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> > +	/* RSS table size must be an order of 2 */
> > +	if (rss_rings != (1 << order_base_2(rss_rings)))
> > +		return -EINVAL;
> 
> This is an obscure way to make this kind of test.
> 
> The canonical way is:
> 
> 	if (is_power_of_2(rss_rings))

Which is probably (x & {x-1)) == 0

	David
