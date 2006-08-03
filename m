From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: problems with e1000 and jumboframes
Date: Thu, 3 Aug 2006 17:08:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0608031705560.8443@bizon.gios.gov.pl>
References: <44D1FEB7.2050703@arndnet.de> <20060803135925.GA28348@2ka.mipt.ru>
 <44D20A2F.3090005@arndnet.de> <20060803150330.GB12915@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-1639719408-1154617731=:8443"
Cc: Arnd Hannemann <arnd@arndnet.de>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:8592 "EHLO bizon.gios.gov.pl")
	by vger.kernel.org with ESMTP id S932565AbWHCPI7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2006 11:08:59 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20060803150330.GB12915@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-1639719408-1154617731=:8443
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Thu, 3 Aug 2006, Evgeniy Polyakov wrote:
<CUT>
>> Why? After your explanation that makes sense for me. The driver needs
>> one contiguous chunk for those 9k packet buffer and thus requests a
>> 3-order page of 16k. Or do i still do not understand this?
>
> Correct, except that it wants 32k.
> e1000 logic is following:
> align frame size to power-of-two,
16K?

> then skb_alloc adds a little
> (sizeof(struct skb_shared_info)) at the end, and this ends up
> in 32k request just for 9k jumbo frame.

Strange, why this skb_shared_info cannon be added before first alignment?=
=20
And what about smaller frames like 1500, does this driver behave similar=20
(first align then add)?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-1639719408-1154617731=:8443--
