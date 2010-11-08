From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: Re: [PATCH 0/9] Fix leaking of kernel heap addresses in net/
Date: Mon, 08 Nov 2010 08:13:19 -0500
Message-ID: <1289221999.10229.28.camel@dan>
References: <1289147492.3090.137.camel@Dan>
	 <201011081004.48382.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "chas@cmf.nrl.navy.mil" <chas@cmf.nrl.navy.mil>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"pekkas@netcore.fi" <pekkas@netcore.fi>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"security@kernel.org" <security@kernel.org>,
	"stable@kernel.org" <stable@kernel.org>
To: =?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:49347 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753654Ab0KHNPn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Nov 2010 08:15:43 -0500
In-Reply-To: <201011081004.48382.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Seems like this patch series is incomplete to me as far as /proc/net is 
> concerned.
> 

I'm aware that I missed SCTP, which I will fix in the next attempt.
Other than that (and sticking only to /proc leaks, since I realize there
are many printk examples), care to share what was missed?

-Dan

