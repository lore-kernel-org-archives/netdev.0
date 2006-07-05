From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/3] [PKT_SCHED]: Fix illegal memory dereferences when
	dumping actions
Date: Tue, 04 Jul 2006 21:49:27 -0400
Message-ID: <1152064167.5199.14.camel@jzny2>
References: <20060704220504.787776000@postel.suug.ch>
	 <20060704220549.952720000@postel.suug.ch>  <44AAFCF6.9000706@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.cybersurf.com ([209.197.145.105]:4295 "EHLO
	mx02.cybersurf.com") by vger.kernel.org with ESMTP id S932446AbWGEBt3
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 21:49:29 -0400
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx02.cybersurf.com with esmtp (Exim 4.30)
	id 1FxwWG-0001GM-3D
	for netdev@vger.kernel.org; Tue, 04 Jul 2006 21:49:36 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <44AAFCF6.9000706@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-07 at 01:42 +0200, Patrick McHardy wrote:
> Thomas Graf wrote:
> >  	if (a_o->walk == NULL) {
> > -		printk("tc_dump_action: %s !capable of dumping table\n", kind);
> > +		printk("tc_dump_action: %s !capable of dumping table\n", a_o->kind);
> >  		goto rtattr_failure;
> >  	}
> 
> Can't we just get rid of these printks? This seems like a good
> opportunity.
> 

perhaps convert to DPRINTKs instead

cheers,
jamal


