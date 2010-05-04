From: Benny Amorsen <benny+usenet@amorsen.dk>
Subject: Re: Performance problem in network namespaces
Date: Tue, 04 May 2010 11:48:11 +0200
Message-ID: <m3y6g0m204.fsf@ursa.amorsen.dk>
References: <q2tb9800b71005030225q21365e3ch8dd5b35383a32e8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: =?utf-8?Q?Mart=C3=ADn?= Ferrari <martin.ferrari@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate1.ipvision.dk ([94.127.49.2]:33092 "EHLO gate1.ipvision.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750948Ab0EDJst convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 05:48:49 -0400
In-Reply-To: <q2tb9800b71005030225q21365e3ch8dd5b35383a32e8a@mail.gmail.com>
	(=?utf-8?Q?=22Mart=C3=ADn?= Ferrari"'s message of "Mon, 3 May 2010 11:25:20
 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mart=C3=ADn Ferrari <martin.ferrari@gmail.com> writes:

> When running some benchmarks to test the feasibility of using
> namespaces for emulating networks, I have found a big drop in
> performance when one of the namespaces is performing routing of
> packets.

Is this problem specific to vnet, or do the other types of interfaces
suffer from it as well? (phys, vlan, macvlan...)


/Benny

