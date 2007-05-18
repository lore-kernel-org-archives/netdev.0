From: jamal <hadi@cyberus.ca>
Subject: Re: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small
	packets xmits
Date: Fri, 18 May 2007 08:07:20 -0400
Message-ID: <1179490040.4060.15.camel@localhost>
References: <adahcqdpz1p.fsf@cisco.com>
	 <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
	 <20070515.143207.80029051.davem@davemloft.net>
	 <1179267467.4080.33.camel@localhost>
	 <1179353523.10414.12.camel@w-sridhar2.beaverton.ibm.com>
	 <1179355932.4084.19.camel@localhost>  <1179372347.4084.39.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, xma@us.ibm.com,
	rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, ashwin.chaugule@celunite.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Auke <auke-jan.h.kok@intel.com>, Gagan Arneja <gagan@vmware.com>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.233]:35765 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757081AbXERMH1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2007 08:07:27 -0400
Received: by wx-out-0506.google.com with SMTP id h31so870108wxd
        for <netdev@vger.kernel.org>; Fri, 18 May 2007 05:07:24 -0700 (PDT)
In-Reply-To: <1179372347.4084.39.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-16-05 at 23:25 -0400, jamal wrote:

> 
> This patch now includes two changed drivers (tun and e1000). I have
> tested tun with this patch. I tested e1000 earlier and i couldnt find
> any issues - although as the tittle says its a WIP.
> 
> As before you need net-2.6. You also need the qdisc restart cleanup
> patch.
> 

I have found a bug on e1000 which manifests under a lot of pounding with
traffic.
I am not gonna be posting the patch anymore - but will continue to fix
and add things. If you want the patches email me privately.

cheers,
jamal

