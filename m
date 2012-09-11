From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/2] netprio_cgroup: Optimize the priomap copy loop slightly
Date: Tue, 11 Sep 2012 12:42:23 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE9@saturn3.aculab.com>
References: <20120911112231.13852.61794.stgit@srivatsabhat.in.ibm.com> <20120911112237.13852.1095.stgit@srivatsabhat.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: <john.r.fastabend@intel.com>, <gaofeng@cn.fujitsu.com>,
	<eric.dumazet@gmail.com>, <mark.d.rustad@intel.com>,
	<lizefan@huawei.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>,
	<davem@davemloft.net>, <nhorman@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <20120911112237.13852.1095.stgit@srivatsabhat.in.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PiAtCWZvciAoaSA9IDA7DQo+IC0JICAgICBvbGRfcHJpb21hcCAmJiAoaSA8IG9sZF9wcmlvbWFw
LT5wcmlvbWFwX2xlbik7DQo+IC0JICAgICBpKyspDQo+IC0JCW5ld19wcmlvbWFwLT5wcmlvbWFw
W2ldID0gb2xkX3ByaW9tYXAtPnByaW9tYXBbaV07DQo+ICsJaWYgKG9sZF9wcmlvbWFwKSB7DQo+
ICsJCW9sZF9sZW4gPSBvbGRfcHJpb21hcC0+cHJpb21hcF9sZW47DQo+ICsNCj4gKwkJZm9yIChp
ID0gMDsgaSA8IG9sZF9sZW47IGkrKykNCj4gKwkJCW5ld19wcmlvbWFwLT5wcmlvbWFwW2ldID0g
b2xkX3ByaW9tYXAtPnByaW9tYXBbaV07DQo+ICsJfQ0KDQpPcjoNCgltZW1jcHkobmV3X3ByaW9t
YXAtPnByaW9tYXAsIG9sZF9wcmlvbWFwLT5wcmlvbWFwLA0KCQlvbGRfcHJpb21hcC0+cHJpb21h
cF9sZW4gKiBzaXplb2Ygb2xkX3ByaW9tYXAtPnByaW9tYXBbMF0pOw0KDQoJRGF2aWQNCg0K
