From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: Stale IPv6 address accumulation on linux 3.2.17
Date: Mon, 21 Oct 2013 15:50:24 +0000
Message-ID: <2134F8430051B64F815C691A62D9831813520C@XCH-BLV-504.nw.nos.boeing.com>
References: <Pine.LNX.4.61.1303241153000.20041@envy.nxs.se>
 <CAEwTi7Rbo3dBqhyDJXYvrkMWfrX9xwUr5VovFoW7BfPAZp4XFw@mail.gmail.com>
 <Pine.LNX.4.61.1303272104470.20041@envy.nxs.se>
 <51535D16.4080207@katalix.com> <loom.20131021T165114-650@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-mbsout-01.boeing.com ([130.76.32.231]:54923 "EHLO
	blv-mbsout-01.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752729Ab3JUP6Z convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 11:58:25 -0400
Received: from blv-mbsout-01.boeing.com (localhost.localdomain [127.0.0.1])
	by blv-mbsout-01.boeing.com (8.14.4/8.14.4/DOWNSTREAM_MBSOUT) with ESMTP id r9LFoPwU009811
	for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 08:50:25 -0700
Received: from XCH-NWHT-11.nw.nos.boeing.com (xch-nwht-11.nw.nos.boeing.com [130.247.25.114])
	by blv-mbsout-01.boeing.com (8.14.4/8.14.4/UPSTREAM_MBSOUT) with ESMTP id r9LFoPeu009800
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Mon, 21 Oct 2013 08:50:25 -0700
In-Reply-To: <loom.20131021T165114-650@post.gmane.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On linux 3.2.17, I have a host that configures IPv6 addresses on
an eth0 interface based on Router Advertisements received from an
on-link linux box configured as an IPv6 router and running radvd.
When the host gets an RA, it configures both an EUI-64-based IPv6
address and an IPv6 privacy address, so it has two IPv6 addresses.
But, if I leave the host up for long periods of time, it seems to
accumulate additional IPv6 addresses - perhaps these are stale
IPv6 privacy addresses?

Is this known behavior, and if so is there a way to turn it off?
Or, perhaps this was a known bug that has been corrected in more
recent linux kernel versions?

Thanks - Fred
fred.l.templin@boeing.com
