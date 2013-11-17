From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: kernel BUG at net/core/skbuff.c:2839 RIP  [<ffffffff819109a2>]
 skb_segment+0x6b2/0x6d0
Date: Sun, 17 Nov 2013 19:59:56 +0000 (UTC)
Message-ID: <slrnl8i828.8ar.xiyou.wangcong@linux-6brj.site>
References: <1287049824.20131117201744@eikelenboom.it>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:44121 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006Ab3KQUAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Nov 2013 15:00:19 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Vi8W0-0003Ov-RE
	for netdev@vger.kernel.org; Sun, 17 Nov 2013 21:00:16 +0100
Received: from c-24-5-209-215.hsd1.ca.comcast.net ([24.5.209.215])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 21:00:16 +0100
Received: from xiyou.wangcong by c-24-5-209-215.hsd1.ca.comcast.net with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sun, 17 Nov 2013 21:00:16 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 17 Nov 2013 at 19:17 GMT, Sander Eikelenboom <linux@eikelenboom.it> wrote:
> Hi Eric,
>
> With the linux-net changes from this merge window i get the kernel panic below (not with 3.12.0).
>
> It's on a machine running Xen, 2x rtl8169 nic, and using a bridge for guest networking.
> This panic in the host kernel only seems to occur when generating a lot of network traffic to and from a guest.
>
> I tried reverting "tcp: gso: fix truesize tracking" 0d08c42cf9a71530fef5ebcfe368f38f2dd0476f, but that didn't help.
>
> --
> Sander
>
> [ 1164.511712] ------------[ cut here ]------------
> [ 1164.518446] kernel BUG at net/core/skbuff.c:2839!

This is discussed in another long thread:
http://marc.info/?t=138419721200049&r=1&w=2
