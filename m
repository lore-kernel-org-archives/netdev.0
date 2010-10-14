From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: tbf/htb qdisc limitations
Date: Thu, 14 Oct 2010 08:50:05 +0000
Message-ID: <20101014085005.GA8349@ff.dom.local>
References: <AANLkTin_jPp+WEkyJkD_KZyrJ4WX_6dM5wtFNw_ixuzv@mail.gmail.com> <20101012101022.GA8578@ff.dom.local> <AANLkTikQkCcPXtRQGp=MQrjrWtae84VzbENn5x+1yC47@mail.gmail.com> <20101012215932.GA1945@del.dom.local> <4CB4DE6E.7030802@hp.com> <20101013062649.GA6915@ff.dom.local> <20101013233653.1e363692.billfink@mindspring.com> <20101014064404.GA6219@ff.dom.local> <20101014031354.e172d737.billfink@mindspring.com> <20101014080939.GA7710@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rick Jones <rick.jones2@hp.com>,
	Steven Brudenell <steven.brudenell@gmail.com>,
	netdev@vger.kernel.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:57399 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755095Ab0JNJsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 05:48:47 -0400
Received: by bwz15 with SMTP id 15so214912bwz.19
        for <netdev@vger.kernel.org>; Thu, 14 Oct 2010 02:48:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20101014080939.GA7710@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 14, 2010 at 08:09:39AM +0000, Jarek Poplawski wrote:
> On Thu, Oct 14, 2010 at 03:13:54AM -0400, Bill Fink wrote:
> > TSO/GSO was disabled and was using 9000-byte jumbo frames
> > (and specified mtu 9000 to tc command).
> > 
> > Here was one attempt I made using tbf:
> > 
> > tc qdisc add dev eth2 root handle 1: prio
> > tc qdisc add dev eth2 parent 1:1 handle 10: tbf rate 8900mbit buffer 1112500 limit 10000 mtu 9000
> > tc filter add dev eth2 protocol ip parent 1: prio 1 u32 match ip dst 192.168.1.23 flowid 10:1
> > 
> > I tried many variations of the above, all without success.
> 
> The main problem are smaller packets. If you had (almost) only 9000b
> frames this probably could work. [...]

On the other hand, e.g. the limit above seems too low wrt mtu & rate.

Jarek P.
