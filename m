From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: A problem about ICMP packet-too-big message handler
Date: Wed, 28 Jan 2015 04:45:09 -0800
Message-ID: <1422449109.29618.42.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54C78B8D.1070104@huawei.com>
	 <20150128051929.GA3369592@devbig242.prn2.facebook.com>
	 <54C885D3.70808@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Martin Lau <kafai@fb.com>, netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:36295 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755713AbbA2CAc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 21:00:32 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so27762043iec.7
        for <netdev@vger.kernel.org>; Wed, 28 Jan 2015 18:00:32 -0800 (PST)
In-Reply-To: <54C885D3.70808@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-01-28 at 14:46 +0800, Yang Yingliang wrote:
> On 2015/1/28 13:19, Martin Lau wrote:
> > On Tue, Jan 27, 2015 at 08:58:53PM +0800, Yang Yingliang wrote:
> >> Hi,
> >>
> >> My kernel is 3.10 LTS.
> >>
> >> I got a problem here about handling ICMP packet-too-big message.
> >>
> >> Before sending a packet-too-big packet :
> > The expires should be set by the host _receiving_ the icmpv6 too-big.
> > 
> > Can you spell out some details of the outgoing icmpv6 too-big packet?
> > like, the src/dst ip of the icmpv6 and the original ip packet that triggered the
> > too-big.
> > 
> 
> I don't send too-big packet to trigger the err handling.
> 
> I just only send a ICMPv6 packet which type is ICMPV6_PKT_TOOBIG.

You meant : you received an ICMPv6 packet, or you send it ?
