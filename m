From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] iproute: Add magic cookie to route dump file
Date: Fri, 27 Jul 2012 11:46:29 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FB1@saturn3.aculab.com>
References: <50121F4D.8090606@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Pavel Emelyanov" <xemul@parallels.com>,
	"Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34709 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750736Ab2G0KrW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jul 2012 06:47:22 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06293-07 for <netdev@vger.kernel.org>;
 Fri, 27 Jul 2012 11:47:19 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <50121F4D.8090606@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In order to somehow verify that a blob contains route dump a
> 4-bytes magic is put at the head of the data and is checked
> on restore.

Wouldn't a hash/checksum be useful as well?
Especially if it uneditable data.

	David
