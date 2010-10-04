From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: To GRO or not to GRO...
Date: Mon, 4 Oct 2010 11:48:46 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A136602570A01D@rrsmsx501.amr.corp.intel.com>
References: <4CA7BD60.3010501@sauce.co.nz>	<152341286090326@web67.yandex.ru>
 <20101003.003129.193711520.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "richard@sauce.co.nz" <richard@sauce.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>,
	"sysoleg@yandex.ru" <sysoleg@yandex.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:59744 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798Ab0JDRtE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Oct 2010 13:49:04 -0400
In-Reply-To: <20101003.003129.193711520.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.or=
g] On
>Behalf Of David Miller
>Sent: Sunday, October 03, 2010 12:31 AM
>To: sysoleg@yandex.ru
>Cc: richard@sauce.co.nz; netdev@vger.kernel.org
>Subject: Re: To GRO or not to GRO...
>
>From: "\"Oleg A. Arkhangelsky\"" <sysoleg@yandex.ru>
>Date: Sun, 03 Oct 2010 11:18:46 +0400
>
>>
>>
>> 03.10.2010, 03:17, "Richard Scobie" <richard@sauce.co.nz>:
>>
>>> In the README for ixgbe-2.1.4, is says:
>>>
>>> " Disable GRO when routing/bridging
>>> =A0=A0=A0---------------------------------
>>> =A0=A0=A0Due to a known kernel issue, GRO must be turned off when
>>> routing/bridging.
>>> =A0=A0=A0GRO can be turned off via ethtool."
>>>
>>
>> This information is true for LRO, not GRO.
>
>Right.
>
>> I believe that this appeared when ixgbe was converted from LRO
>> to GRO and all occurrences of LRO was blindly replaced by GRO
>> everywhere.
>
>Someome please submit a patch to fix this, thanks.

The information referenced above is from the README included with the o=
ut-of-tree ixgbe driver which we provide for download at e1000.sf.net.=20

The in-kernel docs are accurate AFAICT.

Thanks,
Emil

