From: Jesse Gross <jesse@nicira.com>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan
 interface RX
Date: Fri, 25 Feb 2011 14:57:04 -0800
Message-ID: <AANLkTimFC5drwt44C7Hpn4YJU-Njksr8Zkiv_RXK_oSL@mail.gmail.com>
References: <4D32FC1C.3010905@simon.arlott.org.uk>
	<201101231845.20505.maciej.rutecki@gmail.com>
	<AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com>
	<201101241625.45367.maciej.rutecki@gmail.com>
	<loom.20110205T163216-459@post.gmane.org>
	<AANLkTi=-+1dnh5ab6nMwjwMx20jpirYyaASZ=dk4OExp@mail.gmail.com>
	<loom.20110206T203347-475@post.gmane.org>
	<4D4FE100.5090808@gmail.com>
	<loom.20110214T141934-88@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: chriss <mail_to_chriss@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:47945 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932539Ab1BYW5G convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 17:57:06 -0500
Received: by vws12 with SMTP id 12so1804785vws.19
        for <netdev@vger.kernel.org>; Fri, 25 Feb 2011 14:57:05 -0800 (PST)
In-Reply-To: <loom.20110214T141934-88@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 14, 2011 at 5:22 AM, chriss <mail_to_chriss@gmx.net> wrote:
> Nicolas de Peslo=FCan <nicolas.2p.debian <at> gmail.com> writes:
>
>> I think you should have a look at ebtables command, in particular, t=
he
> BROUTING chain of broute
>> table. If this chain ask the packet to be dropped, then bridge will =
ignore it
> and give a chance to
>> the upper layer to use it. Upper layer might be IP, or in your parti=
cular
> setup, VLAN.
>>
>> HTH,
>>
>> =A0 =A0 =A0 Nicolas.
>
> Thank you very much for the ebtables hint.
>
> I also tried to add the vlan to my bridge device but only droping the=
 vlan
> tagged paket with ebtables got it working.
>
> I'm not sure if this is the wanted behavior for bridging vlan actions=
=2E
> ..or my network setup is just to ..f%%%'ed up?!

What driver is in use with the NIC you are seeing this on?
