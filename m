From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [RFC PATCH 3/5] bnx2x: Add support for segmentation of tunnels
 with outer checksums
Date: Wed, 31 Aug 2016 11:31:13 +0000
Message-ID: <DM5PR11MB1723AFE410DF1591E46921AB97E30@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
 <20160419190609.11723.8710.stgit@ahduyck-xeon-server>
 <CO2PR11MB0088207088FA6F6A502AB3B097EA0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uc3CMzvChw2ifaw4Gz+i=udaZsS8m4Qn8adL6ZoXor5wQ@mail.gmail.com>
 <CO2PR11MB008820D7EEE1788F55A3BE4997ED0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <CAKgT0Uf194vxfsMU8-OC2jFQhv7aNbr+gbUzD9uH_o=oyC1=2Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: netdev <netdev@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0130.outbound.protection.outlook.com ([104.47.38.130]:29130
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755315AbcHaLbR (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 07:31:17 -0400
In-Reply-To: <CAKgT0Uf194vxfsMU8-OC2jFQhv7aNbr+gbUzD9uH_o=oyC1=2Q@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

T25lIHF1ZXN0aW9uIEkgaGF2ZSByZWdhcmRpbmcgdGhlIGZlYXR1cmUsIHJlZ2FyZGluZyB0aGUN
CnBhcnRpYWwgb2ZmbG9hZCBjb21wYXRpYmxlIHdpdGggbmRvX2ZlYXR1cmVzX2NoZWNrKCkuDQoN
CkNvbnNpZGVyIHRoZSBmb2xsb3dpbmcgZXhhbXBsZSAtDQpMZXQncyBhc3N1bWUgbXkgYWRhcHRl
ciBpcyBjYXBhYmxlIG9mIGRvaW5nIG91dGVyLWNzdW0gdmFsaWRhdGlvbg0KZm9yIHZ4bGFuIHBh
Y2tldHMsIGJ1dCBvbmx5IGlmIGlubmVyIG5ldHdvcmsgcHJvdG9jb2wgaXMgSVB2NCwNCndoaWxl
IGF0IHRoZSBzYW1lIHRpbWUgaXQncyBjYXBhYmxlIG9mIGRvaW5nIGdzbyBvZmZsb2FkaW5nIGZv
ciBhbnkNCnZ4bGFuLWVuY2Fwc3VsYXRlZCBwYWNrZXQuDQoNCkluIHRoYXQgY2FzZSwgSSdsbCBw
dWJsaXNoIE5FVElGX0ZfR1NPX1VEUF9UVU5ORUxfQ1NVTSBhcw0KcGFydCBvZiBteSBvZmZsb2Fk
IGNhcGFiaWxpdHkgWyYgZW5jYXAgY2FwYWJpbGl0aWVzXSwgYW5kIGluIG15IGRyaXZlcidzDQpp
bXBsZW1lbnRhdGlvbiBvZiBuZG9fZmVhdHVyZXNfY2hlY2soKSBJJ2QgcmVtb3ZlIHRoZSBmZWF0
dXJlIGluIGNhc2UNCkknZCBmaW5kIG91dCBTS0IgaXMgdnhsYW4gd2hvc2UgaW5uZXIgbmV0d29y
ayBwcm90b2NvbCBpcyBpcHY2Lg0KDQpJcyB0aGVyZSBhIHdheSBJIGNvdWxkIGhhdmUgYmVuZWZp
dGVkIGZyb20gdGhlIHBhcnRpYWwgb2ZmbG9hZCBpbiB0aGF0DQpjYXNlPyBJZiBJIHVuZGVyc3Rh
bmQgdGhlIGZlYXR1cmUgY29ycmVjdGx5LCBpZiBJIHdlcmUgdG8gcHVibGlzaA0KVURQX1RVTk5F
TF9DU1VNICB1bmRlciBwYXJ0aWFsLWdzbywgaXQgd291bGQgbWVhbiB0aGF0IHN0YWNrIHdvdWxk
DQpwZWVsIHRoZSBmZWF0dXJlIG9mZiB1bnRpbCBpdCB3b3VsZCBkZWNpZGUgdGhlcmUncyBhY3R1
YWwgbmVlZCBmb3IgU1cgR1NPLA0KdGhlcmVieSBkZW55aW5nIG1lIHRoZSBhYmlsaXR5IG9mIHV0
aWxpemluZyB0aGUgSFcgb2ZmbG9hZCBjYXBhYmlsaXR5IGZvciBDU1VNLg0KDQpBbSBJIHJlYWRp
bmcgaXQgd3Jvbmc/IE9yIGRvZXMgdGhpcyB0cmFkZS1vZmYgZXhpc3Q/DQo=
