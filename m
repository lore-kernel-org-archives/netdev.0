From: jamal <hadi@cyberus.ca>
Subject: Re: [iproute2] tc action mirred    question
Date: Wed, 16 Sep 2009 08:28:19 -0400
Message-ID: <1253104099.4584.9.camel@dogo.mojatatu.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
	 <1252376168.5244.11.camel@dogo.mojatatu.com>
	 <313388.35529.qm@web111617.mail.gq1.yahoo.com>
	 <1252534266.4119.5.camel@dogo.mojatatu.com>
	 <204967.7557.qm@web111613.mail.gq1.yahoo.com>
	 <1252671940.25158.5.camel@dogo.mojatatu.com>
	 <510605.34044.qm@web111611.mail.gq1.yahoo.com>
	 <1252704524.25158.42.camel@dogo.mojatatu.com>
	 <833118.87017.qm@web111618.mail.gq1.yahoo.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux netdev <netdev@vger.kernel.org>
To: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f180.google.com ([209.85.211.180]:37848 "EHLO
	mail-yw0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758890AbZIPMav (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2009 08:30:51 -0400
Received: by ywh10 with SMTP id 10so3497117ywh.1
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2009 05:30:55 -0700 (PDT)
In-Reply-To: <833118.87017.qm@web111618.mail.gq1.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-09-14 at 06:44 -0700, Xiaofei Wu wrote:

> On node A I run 'ping 192.168.1.215'(IP addr of node C eth0) on node A, one request 'only' get one reply. It's strange.
> On node B,
> window1:  'tcpdump -i wlan1 -n -e', I can see the mirroring packets.
> window2:  'tcpdump -i wlan2 -n -e', I see noting.
> It seems that node B didn't forward the mirroring packects. So I did anotner experiment to check it. 
> I am sure node B can forward packets. But it didn't forward the mirroring packets, why?  (something wrong 
> with the mirroring packets?)
> 

Please put some effort - these are things you can resolve on your
own. Many possibilities on node B:

- run netstats to see forwarding stats
- run ping from node B to .215 to see if you can reach it.
- check ARP tables
- add explicit route to .215
- check rpfilter

cheers,
jamal

