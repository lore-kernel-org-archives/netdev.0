From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: i.MX28 based system losing eth0 on boot
Date: Thu, 8 May 2014 01:47:22 +0000
Message-ID: <acba044454de4ade8388d81584e96b33@BLUPR03MB373.namprd03.prod.outlook.com>
References: <CAOk88BLR=nwNGdT++39vLdOt=TwZmemF-trSQPY8AdMN9tKtKQ@mail.gmail.com>
 <20140506181151.GU28564@pengutronix.de>
 <CAOk88BJ+sCtM_cRLuBktUKWYHcPo6KtQ+GAgTJL0zBgQqcQYog@mail.gmail.com>
 <CAGVrzcZs9-f4bCLNv3-s9iubMk8SF8P9+aJaere7rdLbvfo0bw@mail.gmail.com>
 <CAOk88B+5CQZ639S_DwprrdBwZCs9m1cN_hr5hDRVkP18DqHd0w@mail.gmail.com>
 <CAGVrzcbdm-owTaz6ENZMCCGDxQsSaHoEVP=5ex9kZj-FprqUxQ@mail.gmail.com>
 <CAOk88BKmoSytTCXrXgsAGQXhUYvXqCPeX7TmYBRST+K8e0bv3w@mail.gmail.com>
 <CAGVrzcaL6817-WQ73srFHC022QY9LOJwQyx=uxqjHBt+Cf7ZRg@mail.gmail.com>
 <CAOk88BLCq4s8Lb4SLpTS9Mmz2Qe2g5+9ENw7h6huQdXBv_Nq0A@mail.gmail.com>
 <CAGVrzcY0ooeCvu5oQVieW8G4kpzGS6M=d3T8WjxsnZvC8tNXmA@mail.gmail.com>
 <CAOk88BJz3HgQHmYPz9y1i4xn89wjpnGDutLw8wKDguJ1+H3Mjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: =?utf-8?B?VXdlIEtsZWluZS1Lw7ZuaWc=?=
	<u.kleine-koenig@pengutronix.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Fabio.Estevam@freescale.com" <Fabio.Estevam@freescale.com>,
	Jim Baxter <jim_baxter@mentor.com>,
	"Frank.Li@freescale.com" <Frank.Li@freescale.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	kernel <kernel@pengutronix.de>
To: Brian Lilly <brian@crystalfontz.com>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOk88BJz3HgQHmYPz9y1i4xn89wjpnGDutLw8wKDguJ1+H3Mjw@mail.gmail.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

RnJvbTogQnJpYW4gTGlsbHkgPGJyaWFuQGNyeXN0YWxmb250ei5jb20+DQpEYXRhOiBUaHVyc2Rh
eSwgTWF5IDA4LCAyMDE0IDM6NTIgQU0NCg0KPlRvOiBGbG9yaWFuIEZhaW5lbGxpDQo+Q2M6IFV3
ZSBLbGVpbmUtS8O2bmlnOyBEYXZpZCBTLiBNaWxsZXI7IEVzdGV2YW0gRmFiaW8tUjQ5NDk2OyBK
aW0gQmF4dGVyOyBMaSBGcmFuay0NCj5CMjA1OTY7IER1YW4gRnVnYW5nLUIzODYxMTsgbmV0ZGV2
OyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBrZXJuZWwNCj5TdWJqZWN0OiBSZTogaS5N
WDI4IGJhc2VkIHN5c3RlbSBsb3NpbmcgZXRoMCBvbiBib290DQo+DQo+RmxvcmlhbjoNCj4NCj5U
aGFuayB5b3UgZm9yIHlvdXIgaGVscC4NCj4NCj5BZnRlciBkb3VibGluZyB0aGUgdGltZW91dCBs
ZW5ndGggaXQgd29ya2VkLg0KPg0KPkkgbWFuYWdlZCB0byBnZXQgbXkgaGFuZHMgb24gYSBpbXgy
OGV2ayBib2FyZCBhbmQgY29tcGFyZWQgb3VyIGNvbXBvbmVudCBsb2FkDQo+dmVyc3VzIHRoZWly
cywgdG8gZmluZCB0aGV5IGhhdmUgYSAxLjVrIHB1bGwtdXAgb24gRU5FVF9NRElPIHRvICszLjN2
IHdoaWNoIHdhc24ndA0KPnByZXNlbnQgb24gb3VyIGJvYXJkLiAgQWRkaW5nIGEgMS41ayBwdWxs
LXVwIHJlc2lzdG9yIG9uIEVORVRfTURJTyBzb2x2ZXMgdGhlDQo+cHJvYmxlbSwgYW5kIGJvb3Rz
IGFzIGV4cGVjdGVkIHdpdGhvdXQgcGF0Y2hpbmcgYW55dGhpbmcuDQo+DQo+U29ycnkgZm9yIHRo
ZSB0cm91YmxlIG9uIHRoaXMuDQo+DQo+QXBwYXJlbnRseSBvdXIgRUUgaGFkIHNvbWUgcXVlc3Rp
b24gYXMgdG8gd2hldGhlciBvciBub3QgdGhlIHB1bGwtdXAgd2FzIG5lY2Vzc2FyeSwNCj5hbmQg
cHV0IGl0IGluIHRoZSBzY2hlbWF0aWMsIGFuZCB0aGUgZm9vdHByaW50IG9uIHRoZSBib2FyZCwg
YnV0IG1hcmtlZCBpdCBhcyBhDQo+RE5QLCB3aGljaCBvZiBjb3Vyc2UgbGVmdCBpdCBvZmYgdGhl
IGJvYXJkIGFuZCBvdXQgb2YgdGhlIEJPTS4NClsuLi5dDQoNClllcywgMS41SyBwdWxsLXVwIG9u
IE1ESU8gaXMgbmVjZXNzYXJ5LCBvdGhlcndpc2Ugd3JpdGUvcmVhZCBwaHkgcmVnaXN0ZXIgZGF0
YSBpcyBub3QgcmlnaHQgZHVlIHRvIHRoZSBkcml2ZSBzdHJlbmd0aCBpcyBub3QgZW5vdWdoLg0K
DQpUaGFua3MsDQpBbmR5DQo=
