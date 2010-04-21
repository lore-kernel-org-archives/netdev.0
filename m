From: Bijay Singh <Bijay.Singh@guavus.com>
Subject: Selective MD5 Checksum Failuers
Date: Wed, 21 Apr 2010 11:42:54 +0000
Message-ID: <EB1DC92D4496BF4699C950937A61F17805833E@mx1.guavus.com>
References: <C7F354F4.29CC8%scofeldm@cisco.com>
 <201004211326.00974.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="_003_EB1DC92D4496BF4699C950937A61F17805833Emx1guavuscom_"
Cc: "chrisw@redhat.com" <chrisw@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [204.232.241.167] ([204.232.241.167]:17530 "EHLO mx1.guavus.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753207Ab0DULsO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 07:48:14 -0400
In-Reply-To: <201004211326.00974.arnd@arndb.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--_003_EB1DC92D4496BF4699C950937A61F17805833Emx1guavuscom_
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable


I am noticing a strange and a troublesome behavior with tcp md5 checksums. =
Some selective packets are going out with invalid md5 checksums.

The only thing that is changing is the ack number (between the packets with=
 valid and invalid md5 checksums), so while most packets have correct md5 c=
hecksums few 1 in 1000s have md5 checksums errors.

I am on 2.6.26 and I know that there have been significant changes since th=
is version in this area. I have gone thru them but none of issues they addr=
ess seem like the cause for this problem.

I have the scatter/gather and tcp segmentation disabled in the card.

The packet captures are attached.

Bijay

--_003_EB1DC92D4496BF4699C950937A61F17805833Emx1guavuscom_
Content-Type: application/octet-stream;
	name="md5sum-2010-04-16.pcap1-754478487"
Content-Description: md5sum-2010-04-16.pcap1-754478487
Content-Disposition: attachment;
	filename="md5sum-2010-04-16.pcap1-754478487"; size=126;
	creation-date="Wed, 21 Apr 2010 11:38:03 GMT";
	modification-date="Wed, 21 Apr 2010 09:40:25 GMT"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAhFvIS3I7AABWAAAAVgAAAAAAACEOBwAhm5mPewgARQAA
SB6UQABABgAvkOgGkpDk8461VwCzz3kL9Cz4bZfQEAbhz9cAAAEBCArlra80u6UEiQEBExIkpayS
Xri4opmnZ1Cg+xRQ

--_003_EB1DC92D4496BF4699C950937A61F17805833Emx1guavuscom_
Content-Type: application/octet-stream;
	name="md5sum-2010-04-16.pcap1-754479689"
Content-Description: md5sum-2010-04-16.pcap1-754479689
Content-Disposition: attachment;
	filename="md5sum-2010-04-16.pcap1-754479689"; size=126;
	creation-date="Wed, 21 Apr 2010 11:38:03 GMT";
	modification-date="Wed, 21 Apr 2010 08:57:04 GMT"
Content-Transfer-Encoding: base64

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAhFvIS+BOBABWAAAAVgAAAAAAACEOBwAhm5mPewgARQAA
SB6VQABABgAukOgGkpDk8461VwCzz3kL9Cz4cknQEAbh77cAAAEBCArlrbA/u6UFewEBExLDl9fR
r1mTJ8UTdYXIyJb6

--_003_EB1DC92D4496BF4699C950937A61F17805833Emx1guavuscom_--
