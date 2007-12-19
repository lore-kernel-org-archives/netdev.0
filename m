From: "James Nichols" <jamesnichols3@gmail.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Wed, 19 Dec 2007 13:12:41 -0500
Message-ID: <83a51e120712191012r64783b7dk56cc4fbcbdd5685c@mail.gmail.com>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
	 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
	 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
	 <4768123A.7040603@cosmosbay.com>
	 <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
	 <47682F8C.20205@cosmosbay.com>
	 <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
	 <47694FCC.1020507@cosmosbay.com>
	 <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
	 <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric Dumazet" <dada1@cosmosbay.com>, linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Jan Engelhardt" <jengelh@computergmbh.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:1635 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbXLSSMm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 13:12:42 -0500
Received: by fg-out-1718.google.com with SMTP id e21so504995fga.17
        for <netdev@vger.kernel.org>; Wed, 19 Dec 2007 10:12:41 -0800 (PST)
In-Reply-To: <Pine.LNX.4.64.0712191857270.12329@fbirervta.pbzchgretzou.qr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The router could be sooo crappy that it drops all packets from
> TCP streams that have SACK enabled and the client has opened
> 200+ SACK connections previously... something like that?

I don't know, maybe.  My router is a fairly new model Cisco and is
pretty major (i.e. pretty expensive), so it's not just a total piece
of crap.  Plus, I never restart it when I see these issues.  I just
turn tcp_sack off, the problem goes away, and I'm able to renable
tcp_sack a few hours later and it works fine until many hours later
when I see the SYN_SENT problem again.
