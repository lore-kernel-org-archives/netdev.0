From: "Zhangjie (HZ)" <zhangjie14@huawei.com>
Subject: [QA-TCP] How to send tcp small packages immediately?
Date: Fri, 24 Oct 2014 15:41:17 +0800
Message-ID: <544A029D.3080508@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
To: <kvm@vger.kernel.org>, Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<liuyongan@huawei.com>, <qinchuanyu@huawei.com>
Return-path: <kvm-owner@vger.kernel.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I use netperf to test the performance of small tcp package, with TCP_NODELAY set :

netperf -H 129.9.7.164 -l 100 -- -m 512 -D

Among the packages I got by tcpdump, there is not only small packages, also lost of
big ones (skb->len=65160).

IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 65160
IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 65160
IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
IP 129.9.7.164.34607 > 129.9.7.186.60840: tcp 0
IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 80
IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 512
IP 129.9.7.186.60840 > 129.9.7.164.34607: tcp 512

SO, how to test small tcp packages? Including TCP_NODELAY, What else should be set?

Thanks!
-- 
Best Wishes!
Zhang Jie

