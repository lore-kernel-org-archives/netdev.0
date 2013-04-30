From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: udp packet not reach application
Date: Tue, 30 Apr 2013 02:15:24 +0000 (UTC)
Message-ID: <kln9fr$25u$1@ger.gmane.org>
References: <517AC60F.9010609@gmail.com> <517E7746.6040802@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:43807 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757025Ab3D3CPk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Apr 2013 22:15:40 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UX06V-0001kI-PE
	for netdev@vger.kernel.org; Tue, 30 Apr 2013 04:15:39 +0200
Received: from 182.241.5.9 ([182.241.5.9])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 04:15:39 +0200
Received: from xiyou.wangcong by 182.241.5.9 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 30 Apr 2013 04:15:39 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Apr 2013 at 13:36 GMT, Min Wang <ser.basis@gmail.com> wrote:
>
> At first, it was working as my app did get udp traffic.
>
> After a while, strace showed that my app stuck at recvfrom, no udp traffic.
>
> But tcpdump did show that the udp traffic was still coming/alive.
>

Try dropwatch to see where the packets get dropped.
