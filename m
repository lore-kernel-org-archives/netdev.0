From: Hannes Frederic Sowa <hannes@redhat.com>
Subject: Re: A problem about ICMP packet-too-big message handler
Date: Wed, 28 Jan 2015 09:42:54 +0100
Message-ID: <1422434574.4678.21.camel@redhat.com>
References: <54C78B8D.1070104@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53612 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752185AbbA2BIW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jan 2015 20:08:22 -0500
In-Reply-To: <54C78B8D.1070104@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2015-01-27 at 20:58 +0800, Yang Yingliang wrote:
> Hi,
> 
> My kernel is 3.10 LTS.
> 
> I got a problem here about handling ICMP packet-too-big message.
> 
> Before sending a packet-too-big packet :
> 
> # ip -6 route list table local
> local ::1 dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80:: dev lo  metric 0 
> local fe80::1 dev lo  metric 0 	//It  does not have expire value

Did you just add a local route or do you also have a corresponding IPv6
address bound to loopback?

Bye,
Hannes
