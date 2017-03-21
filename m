From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 05/13] i40e: rework exit flow of i40e_add_fdir_ethtool
Date: Tue, 21 Mar 2017 21:25:01 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5857DBA534@ORSMSX115.amr.corp.intel.com>
References: <20170320234712.84157-1-jeffrey.t.kirsher@intel.com>
 <20170320234712.84157-6-jeffrey.t.kirsher@intel.com>
 <2871a7df-bdd7-7f74-8326-40bf381e65cd@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:32248 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758392AbdCUVZE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 21 Mar 2017 17:25:04 -0400
In-Reply-To: <2871a7df-bdd7-7f74-8326-40bf381e65cd@cogentembedded.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PiAtLS0tLU9yaWdpbmFsIE1lc3NhZ2UtLS0tLQ0KPiBGcm9tOiBTZXJnZWkgU2h0eWx5b3YgW21h
aWx0bzpzZXJnZWkuc2h0eWx5b3ZAY29nZW50ZW1iZWRkZWQuY29tXQ0KPiBTZW50OiBUdWVzZGF5
LCBNYXJjaCAyMSwgMjAxNyAzOjExIEFNDQo+IFRvOiBLaXJzaGVyLCBKZWZmcmV5IFQgPGplZmZy
ZXkudC5raXJzaGVyQGludGVsLmNvbT47IGRhdmVtQGRhdmVtbG9mdC5uZXQNCj4gQ2M6IEtlbGxl
ciwgSmFjb2IgRSA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPjsgbmV0ZGV2QHZnZXIua2VybmVs
Lm9yZzsNCj4gbmhvcm1hbkByZWRoYXQuY29tOyBzYXNzbWFubkByZWRoYXQuY29tOyBqb2dyZWVu
ZUByZWRoYXQuY29tDQo+IFN1YmplY3Q6IFJlOiBbbmV0LW5leHQgMDUvMTNdIGk0MGU6IHJld29y
ayBleGl0IGZsb3cgb2YgaTQwZV9hZGRfZmRpcl9ldGh0b29sDQo+IA0KPiBIZWxsbyENCj4gDQo+
IE9uIDMvMjEvMjAxNyAyOjQ3IEFNLCBKZWZmIEtpcnNoZXIgd3JvdGU6DQo+IA0KPiA+IEZyb206
IEphY29iIEtlbGxlciA8amFjb2IuZS5rZWxsZXJAaW50ZWwuY29tPg0KPiA+DQo+ID4gUmVmYWN0
b3IgdGhlIGV4aXQgZmxvdyBvZiB0aGUgaTQwZV9hZGRfZmRpcl9ldGh0b29sIGZ1bmN0aW9uLiBN
b3ZlIHRoZQ0KPiA+IGlucHV0X2xhYmVsIHRvIHRoZSBlbmQgb2YgdGhlIGZ1bmN0aW9uLCByZW1v
dmluZyB0aGUgZGVwZW5kZW5jeSBvbg0KPiANCj4gICAgIEkgZG9uJ3Qgc2VlICdpbnB1dF9sYWJl
bCcgYW55d2hlcmUuIFBlcmhhcHMgJ2ZyZWVfaW5wdXQnIGxhYmVsIHdhcyBtZWFudD8NCj4gDQoN
CllvdSdyZSBjb3JyZWN0LiANCg0KVGhhbmtzLA0KSmFrZQ0KDQo=
