From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Ask some help for the netstat Send-Q
Date: Wed, 17 Feb 2016 18:34:07 +0800
Message-ID: <56C44C9F.8090504@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "David S. Miller" <davem@davemloft.net>, <kuznet@ms2.inr.ac.r>,
	"James Morris" <jmorris@namei.org>, <yoshfuji@linux-ipv6.org>,
	<kaber@trash.net>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:12373 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161041AbcBQKee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 05:34:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David S. Miller and maintainers:

I use the 4.1.16 kernel to build my system and use the iperf to test the netstat, it looks very strange that the client shows:

netstat -at | grep 10.175.112.105                                                                             
tcp        0      0 10.175.112.191:ssh      10.175.112.105:58400    ESTABLISHED                                                     
tcp        0      0 10.175.112.191:33230    10.175.112.105:5001     TIME_WAIT                                                       
tcp        0 4202096 10.175.112.191:33231    10.175.112.105:5001     ESTABLISHED                                                    
tcp        0      0 10.175.112.191:ssh      10.175.112.105:58335    ESTABLISHED  

and the speed is:
 [  3]  0.0-300.0 sec  32.5 GBytes   929 Mbits/sec

It looks like that the speed is fine, But I don't know why the Send-Q has so many buffers, 
the tcp_wmem is big enough and I couldn't found any difference, did I miss something or 
is there something wrong for the TCP config?
Thanks for any suggestion.

Ding
