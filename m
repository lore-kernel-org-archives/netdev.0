From: =?ISO-8859-2?Q?Krzysztof_Ol=EAdzki?= <ole@ans.pl>
Subject: Re: [Bugme-new] [Bug 14685] New: 2.6.30 -> 2.6.31: very high number
 of RX dropped in bnx2
Date: Wed, 02 Dec 2009 14:37:56 +0100
Message-ID: <4B166DB4.9080101@ans.pl>
References: <C27F8246C663564A84BB7AB34397724218065B9853@IRVEXCHCCR01.corp.ad.broadcom.com> <alpine.LNX.1.10.0911301632550.21971@bizon.gios.gov.pl> <1259603093.14964.79.camel@nseg_linux_HP1.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bugzilla-daemon@bugzilla.kernel.org"
	<bugzilla-daemon@bugzilla.kernel.org>,
	"bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:35818 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753937AbZLBNiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2009 08:38:13 -0500
In-Reply-To: <1259603093.14964.79.camel@nseg_linux_HP1.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2009-11-30 18:44, Michael Chan wrote:
> On Mon, 2009-11-30 at 07:33 -0800, Krzysztof Oledzki wrote:
>> # ethtool -S eth0|egrep "(rx_bcast_packets|rx_mcast_packets|
>> rx_fw_discards)"
>>       rx_mcast_packets: 2806
>>       rx_bcast_packets: 790016
>>       rx_fw_discards: 790016
>=20
> This tells me that all the dropped packets are occurring in the iSCSI
> ring.
>=20
> We have recently enabled iSCSI in the kernel and you probably don't h=
ave
> the userspace components to handle the iSCSI ring.  All broadcast
> packets are also received in the iSCSI ring and they are all dropped =
in
> this case without the userspace components.  Networking is not affect=
ed.
> If you rmmod the bnx2i and cnic drivers, the drop counter should stop
> counting.
>=20
> We have newer firmware that will not include dropped iSCSI packets in
> the networking counters.  It should appear in the 2.6.33 kernel
> time-frame.

Yep, it was the cnic driver. Now I feel silly. Thank you for you help=20
and sorry for the noise. I going to close it with RESOLVED-DOCUMENTED.

Best regards,

				Krzysztof Ol=EAdzki
