From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [Bugme-new] [Bug 14685] New: 2.6.30 -> 2.6.31: very high
 number of RX dropped in bnx2
Date: Mon, 30 Nov 2009 03:33:15 -0800
Message-ID: <C27F8246C663564A84BB7AB34397724218065B9853@IRVEXCHCCR01.corp.ad.broadcom.com>
References: <20091125124713.f7ac10e4.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>,
	"olel@ans.pl" <olel@ans.pl>
To: "'Andrew Morton'" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2715 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750797AbZK3LdT convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 06:33:19 -0500
In-Reply-To: <20091125124713.f7ac10e4.akpm@linux-foundation.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:

> > # uptime ; ifconfig eth0|grep "RX p"; ethtool -S eth0|grep disc
> >  01:07:31 up 6 min,  1 user,  load average: 0.00, 0.07, 0.04
> >           RX packets:2234 errors:0 dropped:527 overruns:0 frame:0
> >      rx_discards: 0
> >      rx_fw_discards: 527
> >

Please report rx_bcast_packets and rx_mcast_packets together with
rx_fw_discards.  Thanks.

