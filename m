From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] tcp repair: Fix unaligned access when repairing options
Date: Wed, 25 Apr 2012 15:11:30 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6EF2@saturn3.aculab.com>
References: <4F97EFA9.2080903@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Pavel Emelyanov" <xemul@parallels.com>,
	"David Miller" <davem@davemloft.net>,
	"Linux Netdev List" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:48922 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757398Ab2DYOLi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 10:11:38 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 06624-10 for <netdev@vger.kernel.org>;
 Wed, 25 Apr 2012 15:11:35 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <4F97EFA9.2080903@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> +struct tcp_repair_opt {
> +	__u8	opt_code;
> +	__u16	opt_val;
> +};

That structure has an implied pad field, probably best to
either make it explicit or change the types.

I'd have thought it would do no harm to use two __u32 fields
(unless you really need to save memory somewhere).

	David
