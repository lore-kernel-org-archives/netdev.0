From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: eth1: Detected Hardware Unit Hang
Date: Wed, 31 Mar 2010 13:59:59 -0600
Message-ID: <EA929A9653AAE14F841771FB1DE5A1365FE4D29FF4@rrsmsx501.amr.corp.intel.com>
References: <4BB0C853.2080607@itcare.pl>
 <8DD2590731AB5D4C9DBF71A877482A9061BB3254@orsmsx509.amr.corp.intel.com>
 <4BB0E394.2060908@itcare.pl> <4BB2FE03.4090608@itcare.pl>
 <EA929A9653AAE14F841771FB1DE5A1365FE4CC716B@rrsmsx501.amr.corp.intel.com>
 <4BB39FA2.5000604@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Allan, Bruce W" <bruce.w.allan@intel.com>,
	Linux Network Development list <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: =?iso-8859-2?Q?Pawe=B3_Staszewski?= <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:8944 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757710Ab0CaUAE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 16:00:04 -0400
In-Reply-To: <4BB39FA2.5000604@itcare.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pawe=B3 Staszewski wrote:
> W dniu 2010-03-31 20:03, Tantilov, Emil S pisze:
>> Pawel Staszewski wrote:
>>=20
>>> Hello
>>>=20
>>> I reproduce this problem on other machine with the same hardware an=
d
>>> here is dmesg output: (kernel 2.6.33)
>>>=20
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769395] 0000:04:00.0: eth0:
>>> Detected Hardware Unit Hang: Mar 27 18:19:16 TM_01_C1
>>> [1817894.769396]   TDH<2e>=20
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769397]   TDT<1a>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769397]   next_to_use<1a>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769398]   next_to_clean<2d>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769398]
>>> buffer_info[next_to_clean]: Mar 27 18:19:16 TM_01_C1
>>> [1817894.769399]   time_stamp<11b1591e9>=20
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769399]   next_to_watch<2f>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769400]   jiffies<11b1592e4>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769401]   next_to_watch.status<0>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769401] MAC Status<80080783>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769402] PHY Status<796d>
>>> Mar 27 18:19:16 TM_01_C1 [1817894.769402] PHY 1000BASE-T
>>> Status<3800> Mar 27 18:19:16 TM_01_C1 [1817894.769403] PHY Extended
>>> Status<3000> Mar 27 18:19:16 TM_01_C1 [1817894.769404] PCI
>>> Status<10>=20
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773365] 0000:04:00.0: eth0:
>>> Detected Hardware Unit Hang: Mar 27 18:19:18 TM_01_C1
>>> [1817896.773367]   TDH<2e>=20
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773368]   TDT<1a>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773368]   next_to_use<1a>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773369]   next_to_clean<2d>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773369]
>>> buffer_info[next_to_clean]: Mar 27 18:19:18 TM_01_C1
>>> [1817896.773370]   time_stamp<11b1591e9>=20
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773370]   next_to_watch<2f>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773371]   jiffies<11b1594d8>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773372]   next_to_watch.status<0>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773372] MAC Status<80080783>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773373] PHY Status<796d>
>>> Mar 27 18:19:18 TM_01_C1 [1817896.773373] PHY 1000BASE-T
>>> Status<3800> Mar 27 18:19:18 TM_01_C1 [1817896.773374] PHY Extended
>>> Status<3000> Mar 27 18:19:18 TM_01_C1 [1817896.773375] PCI
>>> Status<10>=20
>>> Mar 27 18:19:20 TM_01_C1 [1817898.769353] 0000:04:00.0: eth0:
>>> Detected=20
>>>=20
>> <snip>
>>=20
>> I have a similar (not the same model) system in the lab with
>> 82573E/L on board, but was not able to reproduce the Tx hangs you
>> reported. So at this point we need to start looking into more
>> details. Could you please file a bug at e1000.sf.net? Include the
>> information you provided so far and also:   =20
>> 1. output from ethtoool -e
>> 2. ethtool -d
>> 3. cat /proc/interrupts
>> 4. full dmesg output from boot to the point where Tx hangs occurred.
>> 5. kernel config file
>>=20
>> Looking at the description of your system (Supermicro X7DCT) I see
>> this board has IPMI option. Do you have IPMI in your system?=20
>>=20
>>=20
> Aditional informations are in attached files.
> Yes there is IPMI option but i don't have it.
>=20
> And yes i will make a bugreport at e1000.sf.net.

Thanks Pawel, for the quick reply. I see that you have disabled flow co=
ntrol. Is that on purpose? What is your link partner?

Thanks,
Emil
