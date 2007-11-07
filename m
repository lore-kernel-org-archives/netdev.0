From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: [PATCH 00/05] ipv6: RFC4214 Support
Date: Tue, 6 Nov 2007 17:15:54 -0800
Message-ID: <39C363776A4E8C4A94691D2BD9D1C9A1029EDBE1@XCH-NW-7V2.nw.nos.boeing.com>
References: <20071106222213.GA22170@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stl-smtpout-01.boeing.com ([130.76.96.56]:47259 "EHLO
	stl-smtpout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755207AbXKGBfj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 20:35:39 -0500
Received: from slb-av-01.boeing.com (slb-av-01.boeing.com [129.172.13.4])
	by stl-smtpout-01.ns.cs.boeing.com (8.14.0/8.14.0/8.14.0/SMTPOUT) with ESMTP id lA71FtYw010878
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 19:16:06 -0600 (CST)
Received: from slb-av-01.boeing.com (localhost [127.0.0.1])
	by slb-av-01.boeing.com (8.14.0/8.14.0/DOWNSTREAM_RELAY) with ESMTP id lA71Ft1A003181
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:15:55 -0800 (PST)
Received: from XCH-NWBH-11.nw.nos.boeing.com (xch-nwbh-11.nw.nos.boeing.com [130.247.55.84])
	by slb-av-01.boeing.com (8.14.0/8.14.0/UPSTREAM_RELAY) with ESMTP id lA71Fsa3003167
	for <netdev@vger.kernel.org>; Tue, 6 Nov 2007 17:15:55 -0800 (PST)
Content-class: urn:content-classes:message
In-Reply-To: <20071106222213.GA22170@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fred L. Templin <fred.l.templin@boeing.com>

The following diffs are specific to the Linux 2.6.23
kernel distribution and implement RFC4214 (Intra-Site
Automatic Tunnel Addressing Protocol - ISATAP). The
affected modules are:

  linux2.6.23/include/linux/if.h
  linux2.6.23/include/net/addrconf.h
  linux2.6.23/net/ipv6/addrconf.c
  linux2.6.23/net/ipv6/sit.c
  linux2.6.23/net/ipv6/Kconfig

and the diffs for each file are included in the following
messages as [PATCH 01/05] through [PATCH 05/05].

The code has been tested under Fedora Core 6 running the
modified 2.6.23 and has been verified in both ISATAP
client and ISATAP router configurations. (The ISATAP
router configuration uses the 'radvd' package.)
Interoperability testing with Windows Vista has also
been performed.

Please advise as to next steps.

Signed-off-by: Fred L. Templin <fred.l.templin@boeing.com>
