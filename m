From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] pktgen: Use seq_puts() where seq_printf() is
 not needed
Date: Fri, 16 May 2014 15:08:06 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1724771A@AcuExch.aculab.com>
References: <090215cd09d88cd79c4e37ff2cc9f7da58205f76.1400237005.git.tgraf@suug.ch>
 <CAADnVQJfmDqeayQUaL7KZLjnQQu8QTiYKJ5wkrMxWdgvKNx8ug@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Alexei Starovoitov' <alexei.starovoitov@gmail.com>,
	Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:55491 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757366AbaEPPIY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 11:08:24 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00862-09 for <netdev@vger.kernel.org>;
 Fri, 16 May 2014 16:08:15 +0100 (BST)
In-Reply-To: <CAADnVQJfmDqeayQUaL7KZLjnQQu8QTiYKJ5wkrMxWdgvKNx8ug@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogQWxleGVpIFN0YXJvdm9pdG92DQo+ID4gLSAgICAgICBzZXFfcHJpbnRmKHNlcSwgImRz
dF9tYWM6ICIpOw0KPiA+ICsgICAgICAgc2VxX3B1dHMoc2VxLCAiZHN0X21hYzogIik7DQo+IA0K
PiB0b3VnaCBsdWNrIG9mIGtlcm5lbCBkZXZlbG9wZXJzLi4uIDspDQo+IE5vcm1hbCBwcmludGYo
KSBHQ0Mgb3B0aW1pemVzIGludG8gcHV0cygpIGF1dG9tYXRpY2FsbHkuDQoNClllcyAtIGEgUElU
QSB3aGVuIHlvdSBhcmUgY29tcGlsaW5nIGZvciBhbiBlbWJlZGRlZCBzeXN0ZW0NCndpdGggYSB2
ZXJ5IGxpbWl0ZWQgJ2xpYmMnLg0KDQpVbmxlc3MgSSB3YXMgYWN0dWFsbHkgd29ycmllZCBhYm91
dCB0aGUgZXhlY3V0aW9uIHRpbWUgSSdkDQpsZWF2ZSB0aGVtIGFzIHNlcV9wcmludGYoKSBmb3Ig
Y29uc2lzdGVuY3kgdGhyb3VnaCB0aGUgZnVuY3Rpb24uDQoNCglEYXZpZA0KDQo=
