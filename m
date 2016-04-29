From: Matthew Finlay <Matt@Mellanox.com>
Subject: Re: [RFC PATCH 2/5] mlx5: Add support for UDP tunnel segmentation
 with outer checksum offload
Date: Fri, 29 Apr 2016 01:18:23 +0000
Message-ID: <49111DBA-CDD6-4D19-9D2D-D6E29675A28F@mellanox.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
 <20160419190603.11723.31623.stgit@ahduyck-xeon-server>
 <CALzJLG-8enmxxvjbVbcygVgM0VhX7Eo=6B=2pZF5jQzN9L9YEg@mail.gmail.com>
 <CAKgT0Uc5poLcTzkeA_8fi2jQeF08zbtj3+obTG1q0ha+ESZRCQ@mail.gmail.com>
 <800B6BE4-251F-4AA5-92FC-3A9393E7981E@mellanox.com>
 <CAKgT0UfsB+CbsCjerxDYkWgdGN01vmf4=VJRLEarFO4_nf-pow@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Alexander Duyck <aduyck@mirantis.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	"Bruce W Allan" <bruce.w.allan@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0071.outbound.protection.outlook.com ([157.56.112.71]:3563
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752352AbcD2B0a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Apr 2016 21:26:30 -0400
In-Reply-To: <CAKgT0UfsB+CbsCjerxDYkWgdGN01vmf4=VJRLEarFO4_nf-pow@mail.gmail.com>
Content-Language: en-US
Content-ID: <F1A9207A1B035C419D2932E4C637AB25@eurprd05.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DQoNCg0KDQoNCj4+DQo+PiBUaGUgbWx4NSBoYXJkd2FyZSByZXF1aXJlcyB0aGUgb3V0ZXIgVURQ
IGNoZWNrc3VtIGlzIG5vdCBzZXQgd2hlbiBvZmZsb2FkaW5nIGVuY2Fwc3VsYXRlZCBwYWNrZXRz
Lg0KPg0KPlRoZSBJbnRlbCBkb2N1bWVudGF0aW9uIHNhaWQgdGhlIHNhbWUgdGhpbmcuICBUaGF0
IHdhcyBkdWUgdG8gdGhlIGZhY3QNCj50aGF0IHRoZSBoYXJkd2FyZSBkaWRuJ3QgY29tcHV0ZXIg
dGhlIG91dGVyIFVEUCBoZWFkZXIgY2hlY2tzdW0uICBJDQo+c3VzcGVjdCB0aGUgTWVsbGFub3gg
aGFyZHdhcmUgaGFzIHRoZSBzYW1lIGlzc3VlLiAgQWxzbyBJIGhhdmUgdGVzdGVkDQo+b24gYSBD
b25uZWN0WC00IGJvYXJkIHdpdGggdGhlIGxhdGVzdCBmaXJtd2FyZSBhbmQgd2hhdCBJIGFtIHNl
ZWluZyBpcw0KPnRoYXQgd2l0aCBteSBwYXRjaGVzIGFwcGxpZWQgdGhlIG91dGVyIGNoZWNrc3Vt
IGlzIGJlaW5nIGNvcnJlY3RseQ0KPmFwcGxpZWQgZm9yIHNlZ21lbnRhdGlvbiBvZmZsb2Fkcy4N
Cj4NCj5NeSB0aG91Z2h0IGlzIHRoYXQgdGhhdCB0aGUgaGFyZHdhcmUgYXBwZWFycyB0byBpZ25v
cmUgdGhlIFVEUA0KPmNoZWNrc3VtIHNvIGlmIGl0IGlzIG5vbi16ZXJvIHlvdSBjYW5ub3QgZ3Vh
cmFudGVlIHRoZSBjaGVja3N1bSB3b3VsZA0KPmJlIGNvcnJlY3Qgb24gdGhlIGxhc3QgZnJhbWUg
aWYgaXQgaXMgYSBkaWZmZXJlbnQgc2l6ZSB0aGFuIHRoZSByZXN0DQo+b2YgdGhlIHNlZ21lbnRz
LiAgSW4gdGhlIGNhc2Ugb2YgdGhlc2UgcGF0Y2hlcyB0aGF0IGlzc3VlIGhhcyBiZWVuDQo+cmVz
b2x2ZWQgYXMgSSBoYXZlIHByZWNvbXB1dGVkIHRoZSBVRFAgY2hlY2tzdW0gZm9yIHRoZSBvdXRl
ciBVRFANCj5oZWFkZXIgYW5kIGFsbCBvZiB0aGUgc2VnbWVudHMgd2lsbCBiZSB0aGUgc2FtZSBs
ZW5ndGggc28gdGhlcmUgc2hvdWxkDQo+YmUgbm8gdmFyaWF0aW9uIGluIHRoZSBVRFAgY2hlY2tz
dW0gb2YgdGhlIG91dGVyIGhlYWRlci4gIFVubGVzcyB5b3UNCj5jYW4gdGVsbCBteSBleGFjdGx5
IHRoZSByZWFzb24gd2h5IHdlIGNhbm5vdCBwcm92aWRlIHRoZSBvdXRlciBVRFANCj5jaGVja3N1
bSBJIHdvdWxkIGFzc3VtZSB0aGF0IHRoZSByZWFzb24gaXMgZHVlIHRvIHRoZSBmYWN0IHRoYXQg
dGhlDQo+aGFyZHdhcmUgZG9lc24ndCBjb21wdXRlIGl0IHNvIHlvdSBjYW5ub3QgaGFuZGxlIGEg
ZnJhZ21lbnQgb24gdGhlIGVuZA0KPndoaWNoIGlzIHJlc29sdmVkIGFscmVhZHkgdmlhIEdTT19Q
QVJUSUFMLg0KDQpJIHdpbGwgY2hlY2sgaW50ZXJuYWxseSBhbmQgdmVyaWZ5IHRoZXJlIGFyZSBu
byB1bmZvcmVzZWVuIGlzc3VlcyB3aXRoIHNldHRpbmcgdGhlIG91dGVyIFVEUCBjaGVja3N1bSBp
biB0aGlzIHNjZW5hcmlvLg0KDQo+DQo+LSBBbGV4DQo=
