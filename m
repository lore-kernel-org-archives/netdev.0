From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: [Bugme-new] [Bug 14685] New: 2.6.30 -> 2.6.31: very high number
 of RX dropped in bnx2
Date: Mon, 30 Nov 2009 16:33:56 +0100 (CET)
Message-ID: <alpine.LNX.1.10.0911301632550.21971@bizon.gios.gov.pl>
References: <C27F8246C663564A84BB7AB34397724218065B9853@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1144830174-851990816-1259595237=:21971"
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:42897 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752908AbZK3Pee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 10:34:34 -0500
In-Reply-To: <C27F8246C663564A84BB7AB34397724218065B9853@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1144830174-851990816-1259595237=:21971
Content-Type: TEXT/PLAIN; charset=iso-8859-2; format=flowed
Content-Transfer-Encoding: 8BIT



On Mon, 30 Nov 2009, Michael Chan wrote:

> Andrew Morton wrote:
>
>>> # uptime ; ifconfig eth0|grep "RX p"; ethtool -S eth0|grep disc
>>>  01:07:31 up 6 min,  1 user,  load average: 0.00, 0.07, 0.04
>>>           RX packets:2234 errors:0 dropped:527 overruns:0 frame:0
>>>      rx_discards: 0
>>>      rx_fw_discards: 527
>>>
>
> Please report rx_bcast_packets and rx_mcast_packets together with
> rx_fw_discards.  Thanks.

# ethtool -S eth0|egrep "(rx_bcast_packets|rx_mcast_packets|rx_fw_discards)"
      rx_mcast_packets: 2806
      rx_bcast_packets: 790016
      rx_fw_discards: 790016

Best regards,

 				Krzysztof Olêdzki
---1144830174-851990816-1259595237=:21971--
