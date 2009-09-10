From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Thu, 10 Sep 2009 22:37:56 +0200
Message-ID: <4AA963A4.5080509@gmail.com>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com> <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52454 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752605AbZIJUh5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 16:37:57 -0400
In-Reply-To: <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Something must be wrong with program or whatever...

On the receiver I did this to trace the latency messages only

# tcpdump -i eth0 not host 239.0.192.2 and port 9002 -n

22:28:07.223300 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
22:28:07.223403 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32

22:28:08.223301 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
22:28:08.223416 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32

22:28:09.223380 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
22:28:09.223494 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32

22:28:10.223481 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
22:28:10.223597 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32

22:28:11.223581 IP 55.225.18.7.9002 > 55.225.18.5.9002: UDP, length 32
22:28:11.223678 IP 55.225.18.5.9002 > 55.225.18.7.9002: UDP, length 32


See how the answer is *very* slow ? Something like > 100 us ?

