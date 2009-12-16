From: "Chilakala, Mallikarjuna" <mallikarjuna.chilakala@intel.com>
Subject: RE: [net-2.6 PATCH v2 1/2] ixgbe: Fix tx_restart_queue/non_eop_desc
 statistics counters
Date: Wed, 16 Dec 2009 09:29:05 -0700
Message-ID: <6A821A2E197F6E4C85FD3440E8AFAD3E61A649CBAA@rrsmsx501.amr.corp.intel.com>
References: <20091215215636.25793.78144.stgit@localhost.localdomain>
	<20091215.211354.189718802.davem@davemloft.net>
	<20091215.231651.144154754.davem@davemloft.net>
 <20091215.231855.107696050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-7
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
To: David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:58652 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934990AbZLPQ3L convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2009 11:29:11 -0500
In-Reply-To: <20091215.231855.107696050.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: David Miller [mailto:davem@davemloft.net]
>Sent: Tuesday, December 15, 2009 11:19 PM
>To: Kirsher, Jeffrey T
>Cc: netdev@vger.kernel.org; gospo@redhat.com; Chilakala, Mallikarjuna;
>Waskiewicz Jr, Peter P
>Subject: Re: [net-2.6 PATCH v2 1/2] ixgbe: Fix tx_restart_queue/non_eo=
p_desc
>statistics counters
>
>From: David Miller <davem@davemloft.net>
>Date: Tue, 15 Dec 2009 23:16:51 -0800 (PST)
>
>> From: David Miller <davem@davemloft.net>
>> Date: Tue, 15 Dec 2009 21:13:54 -0800 (PST)
>>
>>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> Date: Tue, 15 Dec 2009 13:56:59 -0800
>>>
>>>> From: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
>>>>
>>>> Fix the restart_queue and non_eop_desc counters from being
>>>> double-counted.  They are cumulative in each ring, so we don't wan=
t to
>>>> add them to the cumulative result in the adapter's master counter.
>>>> Otherwise, the stats will be inaccurate
>>>>
>>>> Signed-off-by:  Mallikarjuna R Chilakala
><mallikarjuna.chilakala@intel.com>
>>>> Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
>>>> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>>
>>> Applied.
>>
>> So how did you build test this?
>>
>> drivers/net/ixgbe/ixgbe_main.c: In function =A1ixgbe_update_stats=A2=
:
>> drivers/net/ixgbe/ixgbe_main.c:4532: error: invalid type argument of=
 =A1->=A2
>(have =A1struct ixgbe_ring=A2)
>> drivers/net/ixgbe/ixgbe_main.c:4536: error: invalid type argument of=
 =A1->=A2
>(have =A1struct ixgbe_ring=A2)
>
>I'm making the obvious fix "s/->/./", but really....

Thanks Dave for fixing the issue, some changes in Jeff's GIT tree
has created this merge issue. Most likely the order of patches that wer=
e
send out might have created this problem.
