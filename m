From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH V2 net-next 1/3] ipv6: add the IPV6_FL_F_REFLECT flag
 to IPV6_FL_A_GET
Date: Thu, 16 Jan 2014 13:45:18 +0100
Message-ID: <52D7D45E.6000908@enst-bretagne.fr>
References: <1389785403-6401-1-git-send-email-florent.fourcot@enst-bretagne.fr> <20140115224726.GH19945@order.stressinduktion.org> <20140116123515.GD7436@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:56386 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752563AbaAPMp2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 07:45:28 -0500
In-Reply-To: <20140116123515.GD7436@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> Was there a specific reason you did not use np->flow_label here and just
>> mirroring the flowlabel from the first packet of the connection for the
>> whole connection?
>>
>> I don't know if it makes a difference, but maybe it was done on purpose?
> 
> I thought about it and am actually in favor of reusing the flowid from the syn
> packet so userspace does report correct outgoing flowlabel even in case of
> strange tcp peer changing it mid-stream.
> 

Actually, the idea was that the remote could changed the flow label
during the lifetime of a connection.
I do not have a strong opinion on that, but in a "reflect" mode, I
except that the last received value will be in used.

Second, in case of SYN cookie, is the SYN flow label stored somewhere?

Thanks,

Florent.
