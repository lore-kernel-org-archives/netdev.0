From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 1/2] tcp: refactor tcp_retransmit_skb() for a single return point
Date: Mon, 19 Dec 2011 12:10:14 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6D8AF19@saturn3.aculab.com>
References: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA650@USINDEVS02.corp.hds.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <nhorman@tuxdriver.com>, <davem@davemloft.net>,
	<tgraf@infradead.org>, "Seiji Aguchi" <seiji.aguchi@hds.com>,
	<dle-develop@lists.sourceforge.net>
To: "Satoru Moriya" <satoru.moriya@hds.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58673 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752528Ab1LSMLo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 07:11:44 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 18811-09 for <netdev@vger.kernel.org>;
 Mon, 19 Dec 2011 12:11:40 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9CB5AFA650@USINDEVS02.corp.hds.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 
> This is just a cleanup patch for making easy to hook return value
> with a tracepoint.

Another way to temporarily add such a trace, is to temporarily
add a wrapper function.

	David
