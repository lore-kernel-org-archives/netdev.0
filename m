From: "Holger Hoffstaette" <holger.hoffstaette@googlemail.com>
Subject: Re: [PATCH v2] tcp: tsq: restore minimal amount of queueing
Date: Wed, 13 Nov 2013 22:59:50 +0100
Message-ID: <pan.2013.11.13.21.59.50.578858@googlemail.com>
References: <8761s0cqhh.fsf@natisbad.org> <slrnl83jr5.49f.xiyou.wangcong@linux-6brj.site> <87y54u59zq.fsf@natisbad.org> <1384267141.28458.24.camel@edumazet-glaptop2.roam.corp.google.com> <1384353174.28458.110.camel@edumazet-glaptop2.roam.corp.google.com> <8738n0ngq3.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:40700 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654Ab3KMWAF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Nov 2013 17:00:05 -0500
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1VgiTi-000843-1V
	for netdev@vger.kernel.org; Wed, 13 Nov 2013 23:00:02 +0100
Received: from p5086b3f1.dip0.t-ipconnect.de ([80.134.179.241])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 23:00:02 +0100
Received: from holger.hoffstaette by p5086b3f1.dip0.t-ipconnect.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 13 Nov 2013 23:00:02 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Nov 2013 22:18:12 +0100, Arnaud Ebalard wrote:

> Hi Eric,
> 
> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
>> From: Eric Dumazet <edumazet@google.com>
>>
>> After commit c9eeec26e32e ("tcp: TSQ can use a dynamic limit"), several
>> users reported throughput regressions, notably on mvneta and wifi
>> adapters.
>>
>> 802.11 AMPDU requires a fair amount of queueing to be effective.
>>
>> This patch partially reverts the change done in tcp_write_xmit() so that
>> the minimal amount is sysctl_tcp_limit_output_bytes.
> 
> I just tested the fix on current linux tree with the same setup on which I
> observed the regression: it also fixes it on my side on my RN102. Thanks
> for the quick fix, Eric.

+1: fixes spastic NFS & Samba throughput since 3.12.0 with r8169 and e100e
for me as well. It's really not just broken/weird Wifi cards that are
affected by this.

Thanks!

-h
