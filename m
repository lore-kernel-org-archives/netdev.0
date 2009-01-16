From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: RE: [PATCH 2/2] netxen: include ipv6.h (fixes build failure)
Date: Fri, 16 Jan 2009 11:21:24 -0800
Message-ID: <9FB481EF4C70734186A21A64437F637C02A100BB7F@nxexch.unminc.com>
References: <1232130484-25188-1-git-send-email-dhananjay@netxen.com>
	<1232130484-25188-3-git-send-email-dhananjay@netxen.com>
 <20090116.110452.77631610.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1250"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"mingo@elte.hu" <mingo@elte.hu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nxgate.netxen.com ([38.99.60.130]:12798 "EHLO nxexch.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751308AbZAPTVY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2009 14:21:24 -0500
In-Reply-To: <20090116.110452.77631610.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My bad, I copy-pasted the --to --cc list to git command line and missed out the original Sender in that email.

Double apologies to Ingo, first for introducing the build error and other for fixing without credit to reporter :-(.

Thanks Ingo, Dave.

-Dhananjay

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Friday, January 16, 2009 11:05
To: Dhananjay Phadke
Cc: netdev@vger.kernel.org; akpm@linux-foundation.org; linux-kernel@vger.kernel.org; mingo@elte.hu
Subject: Re: [PATCH 2/2] netxen: include ipv6.h (fixes build failure)

From: Dhananjay Phadke <dhananjay@netxen.com>
Date: Fri, 16 Jan 2009 10:28:04 -0800

> Fixes a build error in absence of CONFIG_IPV6:
>
> drivers/net/netxen/netxen_nic_main.c:1189: error: implicit declaration of function 'ipv6_hdr'
> drivers/net/netxen/netxen_nic_main.c:1189: error: invalid type argument of '->'
>
> Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>

Gee, thanks for not even mentioning Ingo having reported this problem
in your commit message. :-((

I've fixed this when committing.

You didn't even CC: him on this patch posting, what gives?


No virus found in this incoming message.
Checked by AVG.
Version: 7.5.526 / Virus Database: 270.10.6/1889 - Release Date: 1/12/2009 20:18


No virus found in this outgoing message.
Checked by AVG.
Version: 7.5.526 / Virus Database: 270.10.6/1889 - Release Date: 1/12/2009 20:18

