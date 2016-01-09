From: "Nelson, Shannon" <shannon.nelson@intel.com>
Subject: RE: WARN trace - skb_warn_bad_offload - vxlan - large udp packet -
 udp checksum disabled
Date: Sat, 9 Jan 2016 00:50:49 +0000
Message-ID: <FC41C24E35F18A40888AACA1A36F3E418AFE338E@fmsmsx115.amr.corp.intel.com>
References: <FC41C24E35F18A40888AACA1A36F3E418AFD00B5@fmsmsx115.amr.corp.intel.com>
 <568DCF2B.2090502@stressinduktion.org>
 <20160107064640.GA27753@unicorn.suse.cz>
 <20160107072742.GC27753@unicorn.suse.cz>
 <20160108191458.GA7266@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@nicira.com>, Jiri Benc <jbenc@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:25696 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756339AbcAIAuv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jan 2016 19:50:51 -0500
In-Reply-To: <20160108191458.GA7266@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: Michal Kubecek [mailto:mkubecek@suse.cz]
>
> Shannon, if disabling UFO works around the problem, please check if this
> patch helps:
> 
> 
> From: Michal Kubecek <mkubecek@suse.cz>
> Date: Fri, 8 Jan 2016 18:23:40 +0100
> Subject: [PATCH] udp: disallow UFO for sockets with SO_NO_CHECK option
> 

Hi Michal,

Yes, that worked for my test case.

Acked-by: Shannon Nelson <shannon.nelson@intel.com>

Thanks,
sln 
