From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: recommended way to support duplicate IP addresses on different
 VLANs?
Date: Mon, 11 Jul 2011 09:48:03 -0600
Message-ID: <4E1B1B33.5060300@genband.com>
References: <4E1B0F86.2040508@mail.usask.ca> <201107111804.26500.remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Friesen <cbf123@mail.usask.ca>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?R=E9mi_Denis-Courmont?= <remi@remlab.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og104.obsmtp.com ([64.18.2.161]:59491 "EHLO
	exprod7og104.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757860Ab1GKPs0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 11:48:26 -0400
In-Reply-To: <201107111804.26500.remi@remlab.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2011 09:04 AM, R=E9mi Denis-Courmont wrote:
> Le lundi 11 juillet 2011 17:58:14 Chris Friesen, vous avez =E9crit :
>> Hi all,
>>
>> We've got a server that sits on multiple VLANs.  Each VLAN is segreg=
ated
>> and doesn't know about the others.  The IP address ranges in each of=
 the
>> VLANs may overlap, and the server may be assigned the same IP addres=
s in
>> multiple VLANs.

>> Is there any other way to deal with this scenario?


> Or then binding sockets to devices (SO_BINDTODEVICE) might work.

Hmm...SO_BINDTODEVICE looks interesting.  I would imagine we'd still=20
need to do some funky stuff around ARP handling.

Chris



--=20
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
