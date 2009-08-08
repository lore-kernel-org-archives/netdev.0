From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Subject: 6lowpan: IPv6 encapsulation question
Date: Sat, 8 Aug 2009 12:23:17 +0400
Message-ID: <20090808082317.GA10925@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pekkas@netcore.fi
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.211.193]:33650 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752778AbZHHIbg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2009 04:31:36 -0400
Received: by ywh31 with SMTP id 31so2681089ywh.4
        for <netdev@vger.kernel.org>; Sat, 08 Aug 2009 01:31:36 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are going to work on the implementation of 6lowpan: the encapsulation
for IPv6 packets for IEEE 802.15.4 networks. RFC 4944 and several
following drafts from 6lowpan WG define several types of IPv6/UDP
headers compression, special fragmentation, ND, etc.

The question is: what is the most clean way to implement 6lowpan and to
hook it into the Linux kernel.

We've identified the following possible ways:

* Implement it just as a special net_device, accepting only IPv6 trafic,
  and splitting/merging it on the top of our IEEE 802.15.4 net_devices

* Implement transmission/fragmentation by hooking into neighbouring output
  routines

* Implement transmission/fragmentation by hooking into dst->output
  routines

* Just hook into IPv6 stack by checking for ARPHRD_IEEE802154 devices

* ???

-- 
With best wishes
Dmitry

