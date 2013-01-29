From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/3][net-next] gianfar: Pack struct gfar_priv_grp into three cachelines
Date: Tue, 29 Jan 2013 14:35:13 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B7124@saturn3.aculab.com>
References: <1359467712-32079-1-git-send-email-claudiu.manoil@freescale.com> <1359467712-32079-2-git-send-email-claudiu.manoil@freescale.com> <1359467712-32079-3-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: "Claudiu Manoil" <claudiu.manoil@freescale.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55935 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753595Ab3A2Ohz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2013 09:37:55 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 24337-10 for <netdev@vger.kernel.org>;
 Tue, 29 Jan 2013 14:37:49 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1359467712-32079-3-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> * remove unused members(!): imask, ievent
> * move space consuming interrupt name strings (int_name_* members) to
> external structures, unessential for the driver's hot path
> * keep high priority hot path data within the first 2 cache lines
> 
> This reduces struct gfar_priv_grp from 6 to 3 cache lines.

Does it really matter where the message texts are allocated?
Provided they aren't intermixed with the 'hot' data.
Allocating them separately just seems over complicated.

	David
