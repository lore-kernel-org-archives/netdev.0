From: thomas yang <lampsu@gmail.com>
Subject: Re: Ethernet CRC questions
Date: Thu, 31 Dec 2009 00:19:45 +0800
Message-ID: <f4f837ab0912300819i5fd35ee4o3e0ff4b16362ba0b@mail.gmail.com>
References: <f4f837ab0912290917h626bcfecy34fe095a878e733c@mail.gmail.com>
	 <1262108376.5941.5.camel@localhost>
	 <f4f837ab0912292153l7086b631o6e0012d9049eecdb@mail.gmail.com>
	 <1262169433.2247.15.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f189.google.com ([209.85.216.189]:46147 "EHLO
	mail-px0-f189.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752506AbZL3QTq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 11:19:46 -0500
Received: by pxi27 with SMTP id 27so6931976pxi.4
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2009 08:19:45 -0800 (PST)
In-Reply-To: <1262169433.2247.15.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>
>> Does the Ethernet frame CRC (generate and verify in hardware) =A0mak=
e
>> the TX / RX =A0rate =A0a little smaller , and a longer end-to-end =A0=
delay ?
>
> Relative to what?
>

Relative to the Ethernet frame without CRC appending / verifying .


In IEEE 802.3 standard, all network devices should append/verify CRC?

>> =A0Could I disable CRC appending / verifying =A0in the network card =
driver
>> =A0 on all of my nodes (machines) ?
>
> Maybe if you want switches to discard everything you send...
>

So, I should disable CRC appending / verifying on all kinds of network
devices in my network?
In this way I will  TX/RX packets more faster ?


--
Thomas
