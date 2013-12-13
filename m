From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 3/6] net_sched: mirred: remove action when the target device is gone
Date: Fri, 13 Dec 2013 12:12:24 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B748D@saturn3.aculab.com>
References: <1386913673-8210-1-git-send-email-xiyou.wangcong@gmail.com> <1386913673-8210-4-git-send-email-xiyou.wangcong@gmail.com> <52AAF895.8090805@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: "Jamal Hadi Salim" <jhs@mojatatu.com>,
	"Cong Wang" <xiyou.wangcong@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:34524 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752900Ab3LMMNd convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 07:13:33 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 29870-04 for <netdev@vger.kernel.org>;
 Fri, 13 Dec 2013 12:13:30 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <52AAF895.8090805@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Jamal Hadi Salim
> Sent: 13 December 2013 12:08
...
> > -	int			tcfm_ok_push;
> > +	unsigned int		tcfm_ok_push:1;
> > +	unsigned int		tcfm_bind:1;
> 
> What has the above cleverness got to do with anything you intended?

Not even 'cleverness'.
Using byte-sized fields is enough to stop the structure growing.
Bit fields are usually not a good idea at all.

	David
