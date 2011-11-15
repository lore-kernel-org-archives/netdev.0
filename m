From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Mon, 14 Nov 2011 20:56:17 -0500
Message-ID: <20111115015616.GA25132@gospo.rdu.redhat.com>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com> <4EC160B4.2040709@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, eric.dumazet@gmail.com,
	bhutchings@solarflare.com, shemminger@vyatta.com, fubar@us.ibm.com,
	andy@greyhouse.net, tgraf@infradead.org, ebiederm@xmission.com,
	mirqus@gmail.com, kaber@trash.net, greearb@candelatech.com,
	jesse@nicira.com, fbl@redhat.com, benjamin.poirier@gmail.com,
	jzupka@redhat.com, ivecera@redhat.com
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752544Ab1KOB4k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Nov 2011 20:56:40 -0500
Content-Disposition: inline
In-Reply-To: <4EC160B4.2040709@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 14, 2011 at 10:40:52AM -0800, Rick Jones wrote:
> On 11/12/2011 12:16 AM, Jiri Pirko wrote:
>> This patch introduces new network device called team. It supposes to be
>> very fast, simple, userspace-driven alternative to existing bonding
>> driver.
>
> What is the definition of "very" here - relative to bonding I presume?  
> Are there actual performance figures available at this point?  Something  
> along the lines of test through both on the same hardware.  I don't have  
> HW on which to run myself but would be quite happy to help with say  
> netperf command selection to demonstrate the difference between the two.
>
> happy benchmrking,
>

On most modern systems I suspect there will be little to no difference
between bonding RX peformance and team performance.

If there is any now, I suspect team and bond performance to be similar
by the time team has to account for the corner-cases bonding has already
resolved.  :-)

Benchmarks may prove otherwise, but I've yet to see Jiri produce
anything.  My initial testing doesn't demonstrate any measureable
differences with 1Gbps interfaces on a multi-core, multi-socket system.
 
