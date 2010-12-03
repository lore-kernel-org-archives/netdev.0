From: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Subject: Re: [net-next-2.6 PATCH] ixgbe: fix link behavior for SFP+ when
 driver is brought down
Date: Fri, 3 Dec 2010 14:44:23 -0800
Message-ID: <A78C6259B11833419567082E2DC0C25601D877D4D4@orsmsx508.amr.corp.intel.com>
References: <20101203133151.21637.52883.stgit@localhost.localdomain>
 <20101203.094215.229763630.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_002_A78C6259B11833419567082E2DC0C25601D877D4D4orsmsx508amrc_"
Cc: "Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"bphilips@novell.com" <bphilips@novell.com>
To: "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:43774 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751582Ab0LCWo0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Dec 2010 17:44:26 -0500
In-Reply-To: <20101203.094215.229763630.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_002_A78C6259B11833419567082E2DC0C25601D877D4D4orsmsx508amrc_
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64

T24gRnJpLCAyMDEwLTEyLTAzIGF0IDA5OjQyIC0wODAwLCBEYXZpZCBNaWxsZXIgd3JvdGU6Cj4g
UGxlYXNlIG51bWJlciB5b3VyIHBhdGNoZXMgc28gSSBrbm93IHVuYW1iaWd1b3VzbHkgaW4gd2hp
Y2ggb3JkZXIgdG8KPiBhcHBseSB0aGVtLgo+IAo+IFRoZSBsYXN0IHBhdGNoIGRpZG4ndCBhcHBs
eSBjbGVhbmx5IGJlY2F1c2UgaXhnYmVfdHlwZXMuaCBpbiB5b3VyCj4gdHJlZSBoYXM6Cj4gCj4g
I2RlZmluZSBJWEdCRV9FUlJfU0ZQX1NFVFVQX05PVF9DT01QTEVURSAgICAgICAgLTMwCj4gCj4g
YnV0IHRoYXQgZG9lcyBub3QgZXhpc3QgaW4gbmV0LW5leHQtMi42ICBUaGlzIGRvZXNuJ3QgZXhp
c3QgaW4KPiBuZXQtMi42IGVpdGhlciBzbyBpdCdzIHNvbWV0aGluZyBjb21wbGV0ZWx5IGxvY2Fs
IHRvIHlvdXIgdHJlZXMuCj4gCj4gSSBmaXhlZCBhbGwgb2YgdGhpcyB1cCBhbmQgYXBwbGllZCBp
dCBhbGwsIGJ1dCB0aGlzIHNvcnQgb2Ygc3R1ZmYKPiBuZWVkcyB0byBiZSBzb3J0ZWQgb3V0IGJl
Zm9yZSBJIHNlZSB0aGUgc3VibWlzc2lvbi4gOi0pCgpJIGFwb2xvZ2l6ZSwgdGhlIG1pc3Npbmcg
ZGVmaW5lIHdhcyBpbiB0aGUgcGF0Y2gKCmh0dHA6Ly9wYXRjaHdvcmsub3psYWJzLm9yZy9wYXRj
aC83Mzk0Mi8KCndoaWNoIEkgc2VudCBvdXQgZWFybGllciB0aGlzIHdlZWsuICBJIHdhcyBnb2lu
ZyB0byBzZW5kIHlvdSBvdXQgYQpzdW1tYXJ5IGVtYWlsIGxldHRpbmcgeW91IGtub3cgdGhhdCB0
aGUgc2l4IHBhdGNoZXMgSSBzdWJtaXR0ZWQgd2VyZSBvbgpteSB0cmVlLiBNeSBmYXVsdCB0aGF0
IEkgZGlkIG5vdC4K

--_002_A78C6259B11833419567082E2DC0C25601D877D4D4orsmsx508amrc_
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: signature.asc
Content-Disposition: attachment; filename="signature.asc"; size=491;
	creation-date="Fri, 03 Dec 2010 14:44:23 GMT";
	modification-date="Fri, 03 Dec 2010 14:44:23 GMT"
Content-Transfer-Encoding: base64

LS0tLS1CRUdJTiBQR1AgU0lHTkFUVVJFLS0tLS0KVmVyc2lvbjogR251UEcgdjEuNC4xMSAoR05V
L0xpbnV4KQoKaVFFY0JBQUJBZ0FHQlFKTStYTEFBQW9KRUNUc0NBRHIvRVdVY0pjSC8wVmRCVVFw
WHhEUndKaXB1aHpLa29MYwpQZjNQMTlnMytpWllkanQvRXFxU09WdG5uYU9nUWYzK2JXekkwU04z
NUFWSEphOFVjZGp4NUFzQ0oyWDBPRDJqClQxZ3JJWjlhYjlOOW9aQU4xN0tRRXQvQXRBaUxWR201
QTlaREx1R05ETmMrZHM3eDg4V0hSTExJQmdLTE5iY3oKSmR2QzlZWVdxNlFsR2g4RzNQdndEazZ6
MmpLb2VKZG15d1c1Vkh3NS9iSVQ4ajhpNjZuNkY1dmtSSXN4NGZ4eQpvMUIzSmtWREdxbU1vV1lH
dHlNV2Y2OFVPVkZGL0ExVEhuRytGOEpKZG03UjNOUnlpdmN5dDNGSUpEbm45Wi9jCkkxOWRMNlpO
TzlrdjNXMFJ5cjFmNHJNbW9ETk1tdU9uYzJxUE00UmRrRkJyUTVoK1ZDZFp3clZ6VGtqWFRJdz0K
PWRNUkMKLS0tLS1FTkQgUEdQIFNJR05BVFVSRS0tLS0tCgo=

--_002_A78C6259B11833419567082E2DC0C25601D877D4D4orsmsx508amrc_--
