From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] rtnl_wilddump_request: fix alignment issue for embedded platforms
Date: Thu, 30 Aug 2012 16:51:49 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FC9@saturn3.aculab.com>
References: <1345621133-23583-1-git-send-email-ljaenicke@innominate.com> <1346338894-12600-1-git-send-email-ljaenicke@innominate.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Lutz Jaenicke" <ljaenicke@innominate.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:49483 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1750848Ab2H3QA4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Aug 2012 12:00:56 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 25837-10 for <netdev@vger.kernel.org>;
 Thu, 30 Aug 2012 17:00:51 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1346338894-12600-1-git-send-email-ljaenicke@innominate.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +		/* attribute has to be NLMSG aligned */
> +		struct rtattr ext_req
__attribute__((aligned(NLMSG_ALIGNTO)));

Would it be better to apply the attribute to the definition
of 'struct rtattr' itself ?

	David
