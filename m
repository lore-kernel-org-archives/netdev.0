From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] usbnet: remove generic hard_header_len check
Date: Thu, 13 Feb 2014 11:49:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D0F6BEB0A@AcuExch.aculab.com>
References: <1392249836-27151-1-git-send-email-emilgoode@gmail.com>
 <87fvnn4c2k.fsf@nemi.mork.no> <20140213112016.GA4245@lianli>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Steve Glendinning <steve.glendinning@shawell.net>,
	Oliver Neukum <oneukum@suse.de>,
	"David S. Miller" <davem@davemloft.net>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <edumazet@google.com>,
	Ming Lei <ming.lei@canonical.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>,
	Liu Junliang <liujunliang_ljl@163.com>,
	Octavian Purdila <octavian.purdila@intel.com>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: 'Emil Goode' <emilgoode@gmail.com>,
	=?utf-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:36218 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753162AbaBMLtW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Feb 2014 06:49:22 -0500
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01064-10 for <netdev@vger.kernel.org>;
 Thu, 13 Feb 2014 11:49:20 +0000 (GMT)
In-Reply-To: <20140213112016.GA4245@lianli>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RnJvbTogRW1pbCBHb29kZQ0KPiA+ID4gIGludCBybmRpc19yeF9maXh1cChzdHJ1Y3QgdXNibmV0
ICpkZXYsIHN0cnVjdCBza19idWZmICpza2IpDQo+ID4gPiAgew0KPiA+ID4gKwkvKiBUaGlzIGNo
ZWNrIGlzIG5vIGxvbmdlciBkb25lIGJ5IHVzYm5ldCAqLw0KPiA+ID4gKwlpZiAoc2tiLT5sZW4g
PCBkZXYtPm5ldC0+aGFyZF9oZWFkZXJfbGVuKQ0KPiA+ID4gKwkJcmV0dXJuIDA7DQo+ID4gPiAr
DQo+ID4NCj4gPiBXb3VsZG4ndCBpdCBiZSBiZXR0ZXIgdG8gdGVzdCBhZ2FpbnN0IEVUSF9ITEVO
LCBzaW5jZSB0aGF0IGlzIGEgY29uc3RhbnQNCj4gPiBhbmQgIm9idmlvdXNseSBjb3JyZWN0IiBp
biB0aGlzIGNhc2U/DQo+IA0KPiBTb21lIG1pbmlkcml2ZXJzIGNoYW5nZSB0aGUgZGVmYXVsdCBo
YXJkX2hlYWRlcl9sZW4gdmFsdWUgc28gdXNpbmcgaXQNCj4gZ3VhcmFudGVlcyB0aGF0IHRoZSBw
YXRjaCB3aWxsIG5vdCBtYWtlIGFueSBjaGFuZ2UgdG8gaG93IHRoZSBjb2RlIGlzDQo+IGN1cnJl
bnRseSB3b3JraW5nLiBVc2luZyBFVEhfSExFTiBjb3VsZCBiZSBtb3JlIGluZm9ybWF0aXZlIGFi
b3V0IHdoYXQNCj4gdGhlIG1pbmlkcml2ZXIgc2hvdWxkIGNoZWNrIGJlZm9yZSBwYXNzaW5nIHNr
YnMgdG8gdXNibmV0X3NrYl9yZXR1cm4oKS4NCj4gVGhlbiBJIHRoaW5rIHRoZSBjb21tZW50IHNo
b3VsZCBiZSBjaGFuZ2VkIGFzIHdlbGwuIE15IGludGVudGlvbiB3YXMgdG8NCj4gbm90IG1ha2Ug
YW55IGNoYW5nZXMgdGhhdCBhZmZlY3QgaG93IHRoZSBjb2RlIHdvcmtzIGZvciBkZXZpY2VzIEkg
Y2Fubm90DQo+IHRlc3QsIGJ1dCBJIHRoaW5rIGVpdGhlciB3YXkgaXMgZmluZSBhbmQgaWYgeW91
IGluc2lzdCBvbiBjaGFuZ2luZyBpdA0KPiBsZXQgbWUga25vdy4NCg0KSSB0aGluayB0aGF0IHRl
c3QgaXMgdG8gZW5zdXJlIHRoYXQgdGhlIGRhdGEgcGFzc2VkIHRvIHRoZSBtaW5pLWRyaXZlcg0K
Y29udGFpbnMgdGhlIGV0aGVybmV0IGZyYW1lIGVuY2Fwc3VsYXRpb24gaGVhZGVyICh0aGlzIHR5
cGljYWxseQ0KY29udGFpbnMgdGhlIGFjdHVhbCBmcmFtZSBsZW5ndGggYW5kIHNvbWUgZmxhZ3Mp
IHNvIHRoYXQgdGhlIG1pbmlkcml2ZXINCndvbid0IHJlYWQgb2ZmIHRoZSBlbmQgb2YgdGhlIHVz
YiBkYXRhLg0KDQpBbnkgY2hlY2sgZm9yIHN0dXBpZGx5IHNob3J0IGV0aGVybmV0IGZyYW1lcyB3
b3VsZCBiZSBsYXRlciBvbi4NCklJUkMgdGhlIGFic29sdXRlIG1pbmltdW0gODAyLjMgZXRoZXJu
ZXQgZnJhbWUgaXMgMTcgYnl0ZXMNCihhZnRlciBmcmFtZSBwYWRkaW5nIGhhcyBiZWVuIHN0cmlw
cGVkKS4NCg0KCURhdmlkDQoNCg==
