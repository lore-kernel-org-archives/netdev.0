From: "Banerjee, Debabrata" <dbanerje@akamai.com>
Subject: Re: [PATCH 1/2] ipv6: do not hold route table lock when send ndisc
 probe
Date: Wed, 22 Aug 2012 12:04:37 -0400
Message-ID: <CC5A7885.7DED%dbanerje@akamai.com>
References: <1345520643.12468.6.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
To: Cong Wang <amwang@redhat.com>,
	Debabrata Banerjee <dbavatar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay01.akamai.com ([72.246.2.12]:55760 "EHLO
	prod-mail-xrelay01.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757844Ab2HVQKF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Aug 2012 12:10:05 -0400
In-Reply-To: <1345520643.12468.6.camel@cr0>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the patch. We're discussing how to reach to this code properly
in the lab now. Although we will probably have to modify so it's compliant
with the RFC, by checking if a ndisc_send_ns() has already been queued
within rt->rt6i_idev->cnf.rtr_probe_interval, otherwise it could flood the
network with neighbor discoveries.

-Debabrata

On 8/20/12 11:44 PM, "Cong Wang" <amwang@redhat.com> wrote:

>Hi, Debabrata,
>
>Could you help to test the attached patch below?
>
>Thanks!
>
