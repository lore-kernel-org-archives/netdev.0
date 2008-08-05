From: Krzysztof Oledzki <ole@ans.pl>
Subject: Re: Warning when unloading the nf_conntack module (regression?)
Date: Tue, 5 Aug 2008 14:10:45 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0808051408350.29400@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0808032344510.16818@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042027080.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042039400.4338@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808042130570.23688@bizon.gios.gov.pl>
 <20080804200058.GX28946@ZenIV.linux.org.uk> <20080804203021.GY28946@ZenIV.linux.org.uk>
 <Pine.LNX.4.64.0808042258370.29400@bizon.gios.gov.pl>
 <20080804215649.GZ28946@ZenIV.linux.org.uk> <Pine.LNX.4.64.0808050000360.29400@bizon.gios.gov.pl>
 <Pine.LNX.4.64.0808050301400.29400@bizon.gios.gov.pl>
 <20080805044604.GA28946@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1672466246-1217938245=:29400"
Cc: Arjan van de Ven <arjan@infradead.org>, netdev@vger.kernel.org,
	kaber@trash.net
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:52541 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756827AbYHEMKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 08:10:54 -0400
In-Reply-To: <20080805044604.GA28946@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1672466246-1217938245=:29400
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Tue, 5 Aug 2008, Al Viro wrote:

> On Tue, Aug 05, 2008 at 03:08:17AM +0200, Krzysztof Oledzki wrote:
>> issue seems to be now solved. However, starting from the
>> 9043476f726802f4b00c96d0c4f418dde48d1304, even with NETFILNER=3Dn, there=
 are
>> other duplicated entries:
>>
>> # find /proc/sys -type d |sort|uniq -d
>>
>> /proc/sys/net/core
>> /proc/sys/net/ipv4/route
>> /proc/sys/net/ipv6
>
> ... dealt with by eeb61f719c00c626115852bbc91189dc3011a844.  Or are you
> seeing those again?

No, probably not. Obviously, I'm in wrong HEAD after git-bisecting. Sorry.

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1672466246-1217938245=:29400--
