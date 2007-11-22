From: "Ryousei Takano" <ryousei@gmail.com>
Subject: Re: HTB/HSFC shaping precision
Date: Thu, 22 Nov 2007 11:07:20 +0900
Message-ID: <b30d1c3b0711211807h499923f3p1abe1e63c545de87@mail.gmail.com>
References: <20071120211258.M55249@visp.net.lb>
	 <20071121094710.GA2295@ff.dom.local>
	 <20071121103024.M12218@visp.net.lb>
	 <1195657607.4437.8.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Denys Fedoryshchenko" <denys@visp.net.lb>,
	"Jarek Poplawski" <jarkao2@o2.pl>, netdev@vger.kernel.org,
	takano-ryousei@aist.go.jp
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:18866 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751970AbXKVCHX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2007 21:07:23 -0500
Received: by el-out-1112.google.com with SMTP id v27so1024036ele
        for <netdev@vger.kernel.org>; Wed, 21 Nov 2007 18:07:22 -0800 (PST)
In-Reply-To: <1195657607.4437.8.camel@localhost>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi jamal and denys,

> > One message later, thats what i dreamed about :-)
> > Subject: [RFC][PATCH 1/3] NET_SCHED: PSPacer qdisc module
> > On website they have very good explanation...
> > http://www.gridmpi.org/gridtcp.jsp
>
> That looks interesting - without reading the papers a few questions are
> developing in my brain cells; for example it looks very similar to what
> the chelsio NICs claim to do (which could be a good thing for TCP).
> Whenever i see someone implementing something in hardware, i always get
> flushes of "patents".
>
Thanks for looking our web page.

PSPacer has quite accurate shaping precision.
The point is that special hardware like the chelsio NICs is not required of it.
PSPacer uses a gap packet, whose format is IEEE 802.3x pause frame,
to control the interval between outgoing packets.
As far as I know, it is a unique approach.

Best Regards,
Ryousei Takano
