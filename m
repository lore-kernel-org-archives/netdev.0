From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [Patch net-next] net: clean up skb headers code
Date: Thu, 30 May 2013 13:22:14 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B725B@saturn3.aculab.com>
References: <1369807740-12324-1-git-send-email-amwang@redhat.com> <20130528.233647.1209227470109213894.davem@davemloft.net> <1369856073.1971.2.camel@bwh-desktop.uk.level5networks.com> <20130529194438.GY3333@ritirata.org> <1369861326.1971.43.camel@bwh-desktop.uk.level5networks.com> <AE90C24D6B3A694183C094C60CF0A2F6026B7259@saturn3.aculab.com> <20130530114556.GC2475@ritirata.org> <AE90C24D6B3A694183C094C60CF0A2F6026B725A@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "Ben Hutchings" <bhutchings@solarflare.com>,
	"David Miller" <davem@davemloft.net>, <amwang@redhat.com>,
	<netdev@vger.kernel.org>, <horms@verge.net.au>
To: "David Laight" <David.Laight@ACULAB.COM>,
	"Antonio Quartulli" <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:50293 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752753Ab3E3MWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 May 2013 08:22:41 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 22386-06 for <netdev@vger.kernel.org>;
 Thu, 30 May 2013 13:22:40 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B725A@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiBPZiBjb3Vyc2UgLSB3ZSBuZWVkIHRvIGxvb2sgYXQgdGhlIHZhbHVlIHRoYXQgQUxMX09ORVMo
KQ0KPiBnZW5lcmF0ZXMgaW4gYW4gZXhwcmVzc2lvbi4gU28gdGhlIHRlc3QgcHJpbnQgbmVlZHMg
dG8gYmU6DQo+IAlwcmludGYoIiVoaHggJWhoeCAlaHggJWh4ICV4ICV4ICVseCAlbHggJWxseCAl
bGx4XG4iLA0KPiAJCUFMTF9PTkVTKGEpLCBBTExfT05FUyhiKSwgQUxMX09ORVMoYyksIEFMTF9P
TkVTKGQpLA0KPiAJCUFMTF9PTkVTKGUpLCBBTExfT05FUyhmKSwgQUxMX09ORVMoZyksIEFMTF9P
TkVTKGgpLA0KPiAJCUFMTF9PTkVTKGkpLCBBTExfT05FUyhqKSk7DQo+IHdoaWNoIHRoZW4gZ2l2
ZXMgMHhmZmZmZmZmZiBmb3IgdGhlIGZpcnN0IDQgZW50cmllcy4NCg0KRXhjZXB0IEkgY29waWVk
IHRoZSB3cm9uZyBmb3JtYXQgbGluZSA6LSggSXQgc2hvdWxkIGJlOg0KIAlwcmludGYoIiV4ICV4
ICV4ICV4ICV4ICV4ICVseCAlbHggJWxseCAlbGx4XG4iLA0KIAkJQUxMX09ORVMoYSksIEFMTF9P
TkVTKGIpLCBBTExfT05FUyhjKSwgQUxMX09ORVMoZCksDQogCQlBTExfT05FUyhlKSwgQUxMX09O
RVMoZiksIEFMTF9PTkVTKGcpLCBBTExfT05FUyhoKSwNCiAJCUFMTF9PTkVTKGkpLCBBTExfT05F
UyhqKSk7DQoNCglEYXZpZA0KDQo=
