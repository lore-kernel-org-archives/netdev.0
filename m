From: Xiaofei Wu <xiaofei_wu08@yahoo.com>
Subject: Re: [iproute2] tc action mirred    question
Date: Sun, 20 Sep 2009 02:58:23 -0700 (PDT)
Message-ID: <908876.76571.qm@web111609.mail.gq1.yahoo.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>  <1252376168.5244.11.camel@dogo.mojatatu.com>  <313388.35529.qm@web111617.mail.gq1.yahoo.com>  <1252534266.4119.5.camel@dogo.mojatatu.com>  <204967.7557.qm@web111613.mail.gq1.yahoo.com>  <1252671940.25158.5.camel@dogo.mojatatu.com>  <510605.34044.qm@web111611.mail.gq1.yahoo.com>  <1252704524.25158.42.camel@dogo.mojatatu.com>  <833118.87017.qm@web111618.mail.gq1.yahoo.com> <1253104099.4584.9.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux netdev <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from n72.bullet.mail.sp1.yahoo.com ([98.136.44.34]:20610 "HELO
	n72.bullet.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754121AbZITKDu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2009 06:03:50 -0400
In-Reply-To: <1253104099.4584.9.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I come across another problem.

network topology:
 M
  |
 A
/  \
B  D
\  /
 C

node M  < ---- > node C
common path: M-A-B-C
the other path: M-A-D-C

With your help I can mirror the outgoing packets(node A wlan0) to wlan1(node A), then transmit it to D. D will route them to C.

There will be another problem.

When the link A-B is not available, there is no packect going out to mirror, node M could not get to node C. (if B is broken, A use ARP to ask the MAC of B's IP addr, but no reply)

So I want to forward the incoming packets( node M -> A(eth0) ) to wlan0(node A) and wlan1(node A) at the same time, route them separately. In this case, if one path is unavailable, it will not influence the other path.

Could iproute2 'tc' do this?


regards,
wu

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 

