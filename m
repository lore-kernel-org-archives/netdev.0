From: Massimo Cetra <ctrix+debianbugs@navynet.it>
Subject: Re: [RFC PATCH] bridge: netfilter: fix skb->nf_bridge NULL panic
 in br_nf_forward_finish
Date: Mon, 09 Jul 2012 11:26:38 +0200
Message-ID: <4FFAA3CE.1090504@navynet.it>
References: <1341584394.4789.34.camel@chief-river-32>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Massimo Cetra <ctrix+debianbugs@navynet.it>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Lin Ming <mlin@ss.pku.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host180-6-static.238-77-b.business.telecomitalia.it ([77.238.6.180]:56732
	"EHLO mailhub2.navynet.it" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752348Ab2GIJ1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 05:27:08 -0400
In-Reply-To: <1341584394.4789.34.camel@chief-river-32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/07/2012 16:19, Lin Ming wrote:
> I can reproduce similiar panic with 3.5-rc5 kernel as Massimo reported at:
> http://marc.info/?l=linux-netdev&m=134089242113979&w=2
>
> The steps to reproduce as follow,
>
> 1. On Host1, setup brige br0(192.168.1.106)
> 2. Boot a kvm guest(192.168.1.105) on Host1 and start httpd
> 3. Start IPVS service on Host1
>     ipvsadm -A -t 192.168.1.106:80 -s rr
>     ipvsadm -a -t 192.168.1.106:80 -r 192.168.1.105:80 -m
> 4. Run apache benchmark on Host2(192.168.1.101)
>     ab -n 1000 http://192.168.1.106/

Thank you Lin,

i spent a couple of days trying to figure out how to reproduce but you 
were quicker and smarter than me.

Massimo
