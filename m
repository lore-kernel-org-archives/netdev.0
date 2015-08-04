From: Oleg A Arkhangelsky <sysoleg@yandex.ru>
Subject: Re: [PATCH 1/1] net/ipv4: Enable flow-based ECMP
Date: Tue, 04 Aug 2015 10:37:07 +0300
Message-ID: <1722301438673827@web16h.yandex.ru>
References: <1438651727-4429-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "jmorris@namei.org" <jmorris@namei.org>
To: Richard Laing <richard.laing@alliedtelesis.co.nz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, pch@ordbogen.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward5h.mail.yandex.net ([84.201.186.23]:34382 "EHLO
	forward5h.mail.yandex.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755055AbbHDHog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 03:44:36 -0400
In-Reply-To: <1438651727-4429-1-git-send-email-richard.laing@alliedtelesis.co.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



04.08.2015, 04:29, "Richard Laing" <richard.laing@alliedtelesis.co.nz>:
> Enable flow-based ECMP.

Looks like your approach is only restricted to the case when sockets ar=
e
involved. What about forwarded traffic (IP routing case)?

Have you seen similar work done by Peter N=C3=B8rlund?

http://comments.gmane.org/gmane.linux.kernel.api/12201

--
wbr, Oleg.

"Anarchy is about taking complete responsibility for yourself."
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 Alan Moore.
