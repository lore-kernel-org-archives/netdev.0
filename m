From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: VLAN and ARP failure on tg3 drivers
Date: Fri, 23 Oct 2009 11:12:46 +0200
Message-ID: <m3zl7i5v8x.fsf@ursa.amorsen.dk>
References: <93821.71108.qm@web32607.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Gertjan Hofman <gertjan_hofman@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:55589 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751338AbZJWJjW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Oct 2009 05:39:22 -0400
In-Reply-To: <93821.71108.qm@web32607.mail.mud.yahoo.com> (Gertjan Hofman's
	message of "Thu, 22 Oct 2009 21:52:42 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gertjan Hofman <gertjan_hofman@yahoo.com> writes:

> Dear Kernel developers,
>
> A couple of weeks ago we tried to migrate from a 2.6.24=C2=A0 kernel =
to a
> 2.6.29 kernel and noticed our VLAN application no longer works.=C2=A0=
 The
> problem is easy to replicate:
>
> 1. connect 2 PC's with a cross-over cable
> 2. set up a fixed IP address to both PC's=C2=A0 (say 192.168.0.[1,2])
> 3. create a vlan:=C2=A0 vconfig=C2=A0 add eth0 0.

VLAN 0 is a special case ("priority tag only"). If you're just trying t=
o
use VLAN's, pick a different number. Also avoid 1001-1024 and 4095 if
you add switches to the mix, because some vendors have odd ideas.


/Benny

