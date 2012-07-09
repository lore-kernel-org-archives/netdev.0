From: Lin Ming <mlin@ss.pku.edu.cn>
Subject: Re: [RFC PATCH] bridge: netfilter: fix skb->nf_bridge NULL panic in br_nf_forward_finish
Date: Mon, 9 Jul 2012 20:00:46 +0800
Message-ID: <CAF1ivSZBMWYc5iKxhX5d_ykkMD4LauFP9M10dBwfmqvpYj=pHg@mail.gmail.com>
References: <1341584394.4789.34.camel@chief-river-32>
	<4FFAA3CE.1090504@navynet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Massimo Cetra <ctrix+debianbugs@navynet.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [124.207.24.138] ([124.207.24.138]:54733 "EHLO
	mail.ss.pku.edu.cn" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753090Ab2GIMBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 08:01:34 -0400
Received: from mail-vb0-f46.google.com (mail-vb0-f46.google.com [209.85.212.46])
	(Authenticated sender: mlin@ss.pku.edu.cn)
	by mail.ss.pku.edu.cn (Postfix) with ESMTPA id 145C4DBC4A
	for <netdev@vger.kernel.org>; Mon,  9 Jul 2012 20:00:50 +0800 (CST)
Received: by vbbff1 with SMTP id ff1so7253739vbb.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 05:00:46 -0700 (PDT)
In-Reply-To: <4FFAA3CE.1090504@navynet.it>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 9, 2012 at 5:26 PM, Massimo Cetra
<ctrix+debianbugs@navynet.it> wrote:
> On 06/07/2012 16:19, Lin Ming wrote:
>>
>> I can reproduce similiar panic with 3.5-rc5 kernel as Massimo reported at:
>> http://marc.info/?l=linux-netdev&m=134089242113979&w=2
>>
>> The steps to reproduce as follow,
>>
>> 1. On Host1, setup brige br0(192.168.1.106)
>> 2. Boot a kvm guest(192.168.1.105) on Host1 and start httpd
>> 3. Start IPVS service on Host1
>>     ipvsadm -A -t 192.168.1.106:80 -s rr
>>     ipvsadm -a -t 192.168.1.106:80 -r 192.168.1.105:80 -m
>> 4. Run apache benchmark on Host2(192.168.1.101)
>>     ab -n 1000 http://192.168.1.106/
>
>
> Thank you Lin,
>
> i spent a couple of days trying to figure out how to reproduce but you were
> quicker and smarter than me.

Could you also test it ? :-)

Thanks.

>
> Massimo
