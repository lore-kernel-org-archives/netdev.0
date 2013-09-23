From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: missing kfree_skb(skb) in ipv6_frag_rcv()?
Date: Mon, 23 Sep 2013 17:42:25 +0000
Message-ID: <2134F8430051B64F815C691A62D983181101B8@XCH-BLV-504.nw.nos.boeing.com>
References: <1379952298.2485.35.camel@bwh-desktop.uk.level5networks.com>
	 <AE90C24D6B3A694183C094C60CF0A2F6026B7354@saturn3.aculab.com>
 <1379955122.2485.47.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: base64
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slb-mbsout-02.boeing.com ([130.76.64.129]:46533 "EHLO
	slb-mbsout-02.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752529Ab3IWRm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Sep 2013 13:42:26 -0400
Received: from slb-mbsout-02.boeing.com (localhost.localdomain [127.0.0.1])
	by slb-mbsout-02.boeing.com (8.14.4/8.14.4/DOWNSTREAM_MBSOUT) with ESMTP id r8NHgQ3C023479
	for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 10:42:26 -0700
Received: from XCH-NWHT-05.nw.nos.boeing.com (xch-nwht-05.nw.nos.boeing.com [130.247.25.109])
	by slb-mbsout-02.boeing.com (8.14.4/8.14.4/UPSTREAM_MBSOUT) with ESMTP id r8NHgPnK023456
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 23 Sep 2013 10:42:26 -0700
In-Reply-To: <1379955122.2485.47.camel@bwh-desktop.uk.level5networks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SGVsbG8sDQoNCkluIHRoZSBtb3N0IHJlY2VudCBrZXJuZWwgcmVsZWFzZXMsIGluIC4vbmV0L2lw
djYvcmVhc3NlbWJseS5jLA0KSSBzZWUgdGhlIGZvbGxvd2luZyBjb2RlIGF0IHRoZSBlbmQgb2Yg
ImlwdjZfZnJhZ19yY3YoKSI6DQoNCisJSVA2X0lOQ19TVEFUU19CSChuZXQsIGlwNl9kc3RfaWRl
dihza2JfZHN0KHNrYikpLCBJUFNUQVRTX01JQl9SRUFTTUZBSUxTKTsNCisJa2ZyZWVfc2tiKHNr
Yik7DQorCXJldHVybiAtMTsNCisNCitmYWlsX2hkcjoNCisJSVA2X0lOQ19TVEFUUyhuZXQsIGlw
Nl9kc3RfaWRldihza2JfZHN0KHNrYikpLCBJUFNUQVRTX01JQl9JTkhEUkVSUk9SUyk7DQorCWlj
bXB2Nl9wYXJhbV9wcm9iKHNrYiwgSUNNUFY2X0hEUl9GSUVMRCwgc2tiX25ldHdvcmtfaGVhZGVy
X2xlbihza2IpKTsNCisJcmV0dXJuIC0xOw0KK30NCg0KUGVyaGFwcyBJIG1pc3NlZCBpdCwgYnV0
IEkgZGlkIG5vdCBmaW5kIGFueXdoZXJlIHRoYXQgJ2ljbXB2Nl9wYXJhbV9wcm9iKCknDQpmcmVl
cyB0aGUgc2tiLCBhbmQgaGVuY2UgaXQgYXBwZWFycyB0aGF0IHRoZXJlIGlzIGEgbWlzc2luZyBr
ZnJlZV9za2IoKQ0KaW4gdGhlIGFib3ZlIGNvZGUuIElzIHRoaXMgYSBidWc/DQoNClRoYW5rcyAt
IEZyZWQNCg==
