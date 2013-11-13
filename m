From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Thu, 14 Nov 2013 00:52:41 +0100
Message-ID: <pan.2013.11.13.23.52.41.470832@googlemail.com>
References: <8761s0cqhh.fsf@natisbad.org> <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org> <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com> <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com> <8738n0ngq3.fsf@natisbad.org> <pan.2013.11.13.21.59.50.578858@googlemail.com> <1384386040.28458.143.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40881 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067Ab3KMXwx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 18:52:53 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VgkEu-0007zp-4I
	for netdev@vger.kernel.org; Thu, 14 Nov 2013 00:52:52 +0100
Received: from p5086b3f1.dip0.t-ipconnect.de ([80.134.179.241])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 00:52:52 +0100
Received: from holger.hoffstaette by p5086b3f1.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 00:52:52 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Nov 2013 15:40:40 -0800, Eric Dumazet wrote:

> On Wed, 2013-11-13 at 22:59 +0100, Holger Hoffstaette wrote:
> 
>> +1: fixes spastic NFS & Samba throughput since 3.12.0 with r8169 and
>> e100e for me as well. It's really not just broken/weird Wifi cards that
>> are affected by this.
> 
> Same remark, it would be nice to pinpoint the problematic driver.

Since I saw this with r8169->r8169 and e1000e->r8169 it's probably
everyone's favourite r8169 :)
Unfortunately I can't be more help but if you can suggest/whip up a fix
I'd be happy to help test.

-h
