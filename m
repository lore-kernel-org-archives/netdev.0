From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 03/15] batman-adv: add biggest_unsigned_int(x) macro
Date: Wed, 25 Apr 2012 15:14:21 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EF3@saturn3.aculab.com>
References: <1335360431-30027-4-git-send-email-ordex@autistici.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <b.a.t.m.a.n@lists.open-mesh.org>
To: "Antonio Quartulli" <ordex@autistici.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49000 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1759154Ab2DYOO3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 10:14:29 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06267-10 for <netdev@vger.kernel.org>;
 Wed, 25 Apr 2012 15:14:26 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1335360431-30027-4-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 

> +/* Returns the biggest unsigned integer with the sizeof x */
> +#define biggest_unsigned_int(x) (~(x)0)

Nope - biggest_unsigned_int(unsigned char) is probably 0xffffffff

	David
