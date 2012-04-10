From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: more accurate skb truesize - regression on Microblaze
Date: Tue, 10 Apr 2012 10:45:44 +0200
Message-ID: <1334047544.3126.14.camel@edumazet-glaptop>
References: <4F83EB0E.4020104@monstr.eu>
	 <1334046444.3126.12.camel@edumazet-glaptop>
	 <1334046746.3126.13.camel@edumazet-glaptop>  <4F83F166.4010208@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	John Williams <john.williams@petalogix.com>,
	David Miller <davem@davemloft.net>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51741 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753478Ab2DJIpt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 04:45:49 -0400
Received: by bkcik5 with SMTP id ik5so3973537bkc.19
        for <netdev@vger.kernel.org>; Tue, 10 Apr 2012 01:45:48 -0700 (PDT)
In-Reply-To: <4F83F166.4010208@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-10 at 10:37 +0200, Michal Simek wrote:
> On 04/10/2012 10:32 AM, Eric Dumazet wrote:
> > On Tue, 2012-04-10 at 10:27 +0200, Eric Dumazet wrote:
> >
> >> BTW, some NIC drivers are known to provide fat skb in their rx path, and
> >> need to be fixed as well. (Some others just lie about skb->truesize to
> >> avoid the tcp slowdown, see my previous iwlwifi patch)
> >>
> >>
> >
> > What is the driver you currently use on your platform ?
> 
> Using Xilinx ll_temac(in mainline) and axi_emac.
> 

OK thanks, could you please give us the content
of /proc/sys/net/ipv4/tcp_rmem ?
