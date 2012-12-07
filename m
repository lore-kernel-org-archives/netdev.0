From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: Experimental network protocol produces "dropping frag"
Date: Fri, 7 Dec 2012 15:41:33 -0800
Message-ID: <E1829B60731D1740BB7A0626B4FAF0A65E0ED86722@XCH-NW-01V.nw.nos.boeing.com>
References: <1354897227.2707.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-mbsout-02.boeing.com ([130.76.64.129]:38735 "EHLO
	slb-mbsout-02.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348Ab2LGXqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 18:46:47 -0500
Received: from slb-mbsout-02.boeing.com (localhost.localdomain [127.0.0.1])
	by slb-mbsout-02.boeing.com (8.14.4/8.14.4/DOWNSTREAM_MBSOUT) with ESMTP id qB7Nfe8b015712
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 15:41:40 -0800
Received: from XCH-NWHT-04.nw.nos.boeing.com (xch-nwht-04.nw.nos.boeing.com [130.247.64.250])
	by slb-mbsout-02.boeing.com (8.14.4/8.14.4/UPSTREAM_MBSOUT) with ESMTP id qB7NfQ47015590
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 7 Dec 2012 15:41:40 -0800
In-Reply-To: <1354897227.2707.10.camel@bwh-desktop.uk.solarflarecom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGVsbG8sDQoNClVuZGVyIHRoZSAzLjIuMTcga2VybmVsLCBJIGFtIHdvcmtpbmcgd2l0aCBhbiBl
eHBlcmltZW50YWwNCnR1bm5lbGluZyBwcm90b2NvbC4gSSBhbSB1c2luZyBpcC1wcm90by0yNTMg
Zm9yIHRoZSBleHBlcmltZW50LA0KYW5kIGhhdmUgY29kZWQgdGhlIHR1bm5lbCBjb2RlIGluIGFz
IGEgbW9kdWxlIHVuZGVyIG5ldC9pcHY0DQpieSBjbG9uaW5nIG5ldC9pcHY0L2lwX2dyZS5jLiBJ
IGhhdmUgYmVlbiB0ZXN0aW5nIHRoZSBtb2R1bGUNCmJ5IHVzaW5nIG1vZHByb2JlIHRvIHJlbG9h
ZCB0aGUgbW9kdWxlIHdpdGhvdXQgcmVib290aW5nIHRoZQ0KbWFjaGluZXMuDQoNCkkgd2FzIHN1
Y2Nlc3NmdWxseSBhYmxlIHRvIHNlbmQgYW5kIHJlY2VpdmUgcGFja2V0cyB2aWEgdGhlDQp0dW5u
ZWwgYW5kIHZlcmlmaWVkIHRoYXQgYm90aCBkaXJlY3Rpb25zIHdlcmUgd29ya2luZyB1c2luZw0K
dGNwZHVtcCBhbmQgd2lyZXNoYXJrIHdoaWNoIHNob3dlZCBpcC1wcm90by0yNTMgcGFja2V0cyBn
b2luZw0KaW4gYm90aCBkaXJlY3Rpb25zLiBTaW5jZSB0aGVuLCBob3dldmVyLCBJIHJlY29tcGls
ZWQgYW5kDQpyZWluaXN0YWxsZWQgdGhlIGVudGlyZSBrZXJuZWwgYW5kIHJlYm9vdGVkIHRoZSBt
YWNoaW5lcy4NCg0KTm93LCBJIGNhbiBzdGlsbCBzZW5kIG15IGlwLXByb3RvLTI1MyBwYWNrZXRz
LCBidXQgb24gdGhlDQpyZWNlaXZpbmcgc2lkZSBJIHNlZSBkbWVzZyBvdXRwdXQgdGhhdCBzYXlz
Og0KDQogICJkcm9wcGluZyBmcmFnIg0KDQpmb3IgZXZlcnkgcGFja2V0IHJlY2VpdmVkLiBUaGUg
aW5wdXQgcGFja2V0cyBhcHBlYXIgdG8gYmUNCmFjY291bnRlZCBmb3Igd2hlbiBJIHR5cGUgImlm
Y29uZmlnIGV0aDAiIChpLmUuLCB0aGUgaW5wdXQNCnBhY2tldCBjb3VudCBpcyBpbmNyZW1lbnRp
bmcpIGJ1dCBwcmludGsncyBmcm9tIG15IHR1bm5lbA0KZHJpdmVyIGNvZGUgYXJlIG5vdCBzaG93
aW5nIHVwIHdoZW4gSSB0eXBlIGRtZXNnIGFuZA0KImlmY29uZmlnIHR1bjAiIG9uIHRoZSB0dW5u
ZWwgaW50ZXJmYWNlIGRvZXMgbm90IHNob3cgYW55DQppbnB1dCBwYWNrZXRzLiBJdCBpcyBhcyBp
ZiB0aGUgcmVjZWl2ZXIgaGFzICJmb3Jnb3R0ZW4iDQpob3cgdG8gZGVhbCB3aXRoIGlwLXByb3Rv
LTI1My4NCg0KQW55IGlkZWFzIG9uIGhvdyBJIG1heSBoYXZlIHNob3QgbXlzZWxmIGluIHRoZSBm
b290LCBhbmQNCndheXMgdG8gcmVjb3Zlcj8NCg0KVGhhbmtzIC0gRnJlZA0KZnJlZC5sLnRlbXBs
aW5AYm9laW5nLmNvbQ0K
