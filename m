From: Andrew Cooper <andrew.cooper3@citrix.com>
Subject: Re: [Xen-devel] [PATCH V3 0/2] limit xen vnic max queues number to
 online cpus number
Date: Fri, 23 Oct 2015 10:50:13 +0100
Message-ID: <562A02D5.9000505@citrix.com>
References: <562A0108.3070501@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
To: Joe Jin <joe.jin@oracle.com>, <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jan Beulich <JBeulich@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.63]:29909 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752932AbbJWJuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 05:50:15 -0400
In-Reply-To: <562A0108.3070501@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23/10/15 10:42, Joe Jin wrote:
> Currently xen vnic allowed to create lots of queues by set module param
> max_queues(both netback and netfront), when queues number larger than
> cpus number, it does not help for performance but need more cpu time.
>
> This patchset limit netback and netfront max queues number to online
> cpus number.
>
> Joe Jin (2):
>   xen-netback: limit xen vif max queues number to online cpus
>   xen-netfront: limit vnic max_queues number to online cpus

Please do not exclude the possibility for making crazy numbers of queues.

I can appreciate the want to prevent people shooting themselves in the
foot, but being able oversubscribe the number of queues is important for
performance testing.

~Andrew
