From: "Fujinaka, Todd" <todd.fujinaka@intel.com>
Subject: RE: [Intel-wired-lan] [PATCH 1/1] igb: Use ARRAY_SIZE instead fo
 sizeof(a)/sizeof(a[0])
Date: Tue, 30 Jun 2015 20:16:29 +0000
Message-ID: <9B4A1B1917080E46B64F07F2989DADD653571BF0@ORSMSX114.amr.corp.intel.com>
References: <1435640130-1466-1-git-send-email-maninder1.s@samsung.com>
	<9B4A1B1917080E46B64F07F2989DADD653571921@ORSMSX114.amr.corp.intel.com>
 <CAFLxGvxayeac0Hq8Gi5j_TJ4dnboYypz9gchW0VQ0Z9t-UFofA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: Maninder Singh <maninder1.s@samsung.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Nelson, Shannon" <shannon.nelson@intel.com>,
	"Wyborny, Carolyn" <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Williams, Mitch A" <mitch.a.williams@intel.com>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"pankaj.m@samsung.com" <pankaj.m@samsung.com>
To: Richard Weinberger <richard.weinberger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:14541 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751767AbbF3UQb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jun 2015 16:16:31 -0400
In-Reply-To: <CAFLxGvxayeac0Hq8Gi5j_TJ4dnboYypz9gchW0VQ0Z9t-UFofA@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

U29ycnkgZm9yIHRoZSB0b3AtcG9zdGluZywgYnV0IEknbSBwcm92aWRlZCB3aXRoIHRoZSB0b29s
cyB0aGV5IGdpdmUgbWUgYW5kIGJvdHRvbSBwb3N0aW5nIGZyb20gT3V0bG9vayBqdXN0IGNvbmZ1
c2VzIGVtYWlsIHRocmVhZHMuIFBsdXMsIHRoaXMgd2FzIGNyb3NzcG9zdGVkIGFsbCBvdmVyIGNy
ZWF0aW9uIGFuZCBjYy1lZCB0byBhbnlvbmUgd2l0aCBhbiBpbnRlbCBhZGRyZXNzLg0KDQpJIHN0
aWxsIHdvdWxkIHNheSBubyBpZiBJJ20gYWxsb3dlZCwgYmVjYXVzZSB0byBndWFyYW50ZWUgdGhh
dCB0aGlzIGNoYW5nZSAtIHRoYXQgSSBkb24ndCB0aGluayBmaXhlcyBhbnl0aGluZyAtIHdvcmtz
IGluIGFsbCBjYXNlcywgd2UgbmVlZCB0byBkbyBhbiBpbmNyZWRpYmxlIGFtb3VudCBvZiByZWdy
ZXNzaW9uIHRlc3RpbmcuIEV2ZXJ5IHZhcmlhbnQgb2YgZXZlcnkgSW50ZWwgcGFydCB0aGF0IHVz
ZXMgdGhpcyBkcml2ZXIgKGFuZCB0aGVyZSBhcmUgbWFueSkgc2hvdWxkIGJlIHRlc3RlZCBhbmQg
d2lsbCBlbmQgdXAgYmVpbmcgdXNlZCBieSB0aGUgY29tbXVuaXR5Lg0KDQpQbHVzLCB5b3UgaGF2
ZSBubyBpZGVhIHRoZSBudW1iZXIgb2Ygb2JzY3VyZSBidWdzIEkgaGF2ZSB0byBkZWFsIHdpdGgg
YXMgdGhlIGd1eSBhbnN3ZXJpbmcgY3VzdG9tZXIgcXVlc3Rpb25zLiBJZiB0aGlzIHRyaWdnZXJz
IHNvbWUgb2RkIGVtYmVkZGVkIGNvbXBpbGVyIGJ1ZywgSSdtIGdvaW5nIHRvIGhhdmUgdG8gZGln
IGl0IG91dC4gVW5sZXNzIHRoZXJlIGlzIGFuIGFjdHVhbCBidWcsIEknZCBsaWtlIHRvIGxlYXZl
IGl0IGFzIGl0IGlzLg0KDQpUb2RkIEZ1amluYWthDQpTb2Z0d2FyZSBBcHBsaWNhdGlvbiBFbmdp
bmVlcg0KTmV0d29ya2luZyBEaXZpc2lvbiAoTkQpDQpJbnRlbCBDb3Jwb3JhdGlvbg0KdG9kZC5m
dWppbmFrYUBpbnRlbC5jb20NCig1MDMpIDcxMi00NTY1DQoNCi0tLS0tT3JpZ2luYWwgTWVzc2Fn
ZS0tLS0tDQpGcm9tOiBSaWNoYXJkIFdlaW5iZXJnZXIgW21haWx0bzpyaWNoYXJkLndlaW5iZXJn
ZXJAZ21haWwuY29tXSANClNlbnQ6IFR1ZXNkYXksIEp1bmUgMzAsIDIwMTUgMTI6MDEgUE0NClRv
OiBGdWppbmFrYSwgVG9kZA0KQ2M6IE1hbmluZGVyIFNpbmdoOyBLaXJzaGVyLCBKZWZmcmV5IFQ7
IEJyYW5kZWJ1cmcsIEplc3NlOyBOZWxzb24sIFNoYW5ub247IFd5Ym9ybnksIENhcm9seW47IFNr
aWRtb3JlLCBEb25hbGQgQzsgVmljaywgTWF0dGhldzsgUm9uY2lhaywgSm9objsgV2lsbGlhbXMs
IE1pdGNoIEE7IGludGVsLXdpcmVkLWxhbkBsaXN0cy5vc3Vvc2wub3JnOyBuZXRkZXZAdmdlci5r
ZXJuZWwub3JnOyBsaW51eC1rZXJuZWxAdmdlci5rZXJuZWwub3JnOyBwYW5rYWoubUBzYW1zdW5n
LmNvbQ0KU3ViamVjdDogUmU6IFtJbnRlbC13aXJlZC1sYW5dIFtQQVRDSCAxLzFdIGlnYjogVXNl
IEFSUkFZX1NJWkUgaW5zdGVhZCBmbyBzaXplb2YoYSkvc2l6ZW9mKGFbMF0pDQoNCk9uIFR1ZSwg
SnVuIDMwLCAyMDE1IGF0IDQ6NTMgUE0sIEZ1amluYWthLCBUb2RkIDx0b2RkLmZ1amluYWthQGlu
dGVsLmNvbT4gd3JvdGU6DQo+IEkgZG9uJ3Qgc2VlIHRoZSByZWFzb24gdGhpcyBpcyBuZWVkZWQg
c28gSSdtIGdvaW5nIHRvIHNheSBOQUsuDQoNClVzaW5nIGdlbmVyaWMgZnVuY3Rpb25zIGlzIGFs
d2F5cyBiZXR0ZXIgdGhhbiBvcGVuIGNvZGVkIHN0dWZmLg0KTGludXgncyBBUlJBWV9TSVpFIGFs
c28gbWFrZXMgc3VyZSB0aGF0IHRoZSBwYXNzZWQgdmFyaWFibGUgaXMgYWN0dWFsbHkgYW4gYXJy
YXkuDQoNCi0tDQpUaGFua3MsDQovL3JpY2hhcmQNCg==
