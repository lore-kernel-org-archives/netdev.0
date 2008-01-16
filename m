From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: Packetlost when "tc qdisc del dev eth0 root"
Date: Wed, 16 Jan 2008 11:54:59 +0300
Message-ID: <478DC663.4000502@bigtelecom.ru>
References: <478C94B7.3070503@bigtelecom.ru> <478CD9D6.3000504@trash.net> <478D226E.1050209@gmail.com> <478D8FC8.9000107@trash.net> <20080116080259.GB1638@ff.dom.local> <478DBADB.1080200@trash.net> <20080116085254.GB2307@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:55132 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751351AbYAPIzH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2008 03:55:07 -0500
In-Reply-To: <20080116085254.GB2307@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =D0=BF=D0=B8=D1=88=D0=B5=D1=82:
> On Wed, Jan 16, 2008 at 09:05:47AM +0100, Patrick McHardy wrote:
> ...
>  =20
>> Yes, thats one possibility (without the dummy device though please).
>> But I wonder what this would actually be useful for. I don't think
>> replacing the root qdisc by a different type is a common scenario,
>> for the same type you can simply use "tc qdisc change", "tc class
>> change" and "tc class replace".
>>
>> Badalian, what are you actually doing?
>>    =20
>
> I'm not sure Vyacheslav needs just this, but I've thought about the
> possibility to recreate the 'shadow' copy of currently used qdisc
> tree (with some updates of course) while it's running. So, the
> possibility of using all the same handles and classids, and even
> dev names if possible, and doing such a switch without any visible
> break.
>
> Jarek P.
>
>  =20
I also think that system must forward all packets what it get if it not=
=20
dropped manual (by iptables or shaper).
Maybe someone need to test delete big TREE.. simple delete, not=20
recreate... linux unavailable some time (if its realy big table its tim=
e=20
may be 10-20 sec on 2xXeon).
I think need helper to do that operations more accurate. Now see=20
situation that linux is PPTP server... its get 2000k connection... try=20
delete qdisc on eth0 (incoming from wan to pptp clients)... i think man=
y=20
sessions will drop.

Thanks!
