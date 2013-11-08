From: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Subject: kernel network panic stack traces on ubuntu 12.04
Date: Fri, 8 Nov 2013 20:40:21 +0000
Message-ID: <2134F8430051B64F815C691A62D9831814D565@XCH-BLV-504.nw.nos.boeing.com>
References: <20131108084654.6935.36501.stgit@nitbit.x32>
 <20131108.152148.475567353347933697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from blv-mbsout-02.boeing.com ([130.76.32.232]:43052 "EHLO
	blv-mbsout-02.boeing.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757511Ab3KHUkX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 15:40:23 -0500
Received: from blv-mbsout-02.boeing.com (localhost.localdomain [127.0.0.1])
	by blv-mbsout-02.boeing.com (8.14.4/8.14.4/DOWNSTREAM_MBSOUT) with ESMTP id rA8KeNYl022244
	for <netdev@vger.kernel.org>; Fri, 8 Nov 2013 12:40:23 -0800
Received: from XCH-PHX-212.sw.nos.boeing.com (xch-phx-212.sw.nos.boeing.com [130.247.25.141])
	by blv-mbsout-02.boeing.com (8.14.4/8.14.4/UPSTREAM_MBSOUT) with ESMTP id rA8KeNI9022238
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 8 Nov 2013 12:40:23 -0800
In-Reply-To: <20131108.152148.475567353347933697.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am hacking the kernel network stack on a Dell running ubuntu 12.04
and when I add code that I know for sure is causing a panic the system
locks up as if it is hung and never prints out a stack trace. The only
way out is to hard reset using the power button. This happens on several
different linux kernel versions - the most recent being 3.10.17. Any
ideas how I can get a stack trace?

Thanks - Fred 
