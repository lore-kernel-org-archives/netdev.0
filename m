From: "James Nichols" <jamesnichols3@gmail.com>
Subject: Re: After many hours all outbound connections get stuck in SYN_SENT
Date: Thu, 20 Dec 2007 11:08:45 -0500
Message-ID: <83a51e120712200808m7fa63e9jc588124a6da5f740@mail.gmail.com>
References: <83a51e120712141239u52d2dd68p1b6ee7ed08f2cecf@mail.gmail.com>
	 <Pine.LNX.4.64.0712181910580.4422@fbirervta.pbzchgretzou.qr>
	 <83a51e120712181021p4c4c2a13g8820271f1e00361b@mail.gmail.com>
	 <4768123A.7040603@cosmosbay.com>
	 <83a51e120712181144l65633b32r72cc369f9d012f47@mail.gmail.com>
	 <47682F8C.20205@cosmosbay.com>
	 <83a51e120712190853q33d9c7c1t4a46380665b7538b@mail.gmail.com>
	 <47694FCC.1020507@cosmosbay.com>
	 <83a51e120712190943m3bf0e2e4v2ea6b660142e9a5a@mail.gmail.com>
	 <47695CEF.4090908@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Jan Engelhardt" <jengelh@computergmbh.de>,
	linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:51686 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755752AbXLTQIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 11:08:47 -0500
Received: by fg-out-1718.google.com with SMTP id e21so604184fga.17
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2007 08:08:46 -0800 (PST)
In-Reply-To: <47695CEF.4090908@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I still dont understand.
>
> "tcpdump -p -n -s 1600 -c 10000" doesnt reveal User data at all.
>
> Without any exact data from you, I am afraid nobody can help.

Oh, I didn't see that you specified specific options.  I'll still have
to anonymize 2000+ IP addresses, but I think there is an open source
tool that will do this for you.



> >> 2) Are you sure you are not using connection tracking, and hit a limit on it ?
> >
> > I'm using ip_conntrack, but the limit I have for max entries is 65K.
> > The most I've seen in there are a couple thousand- that was one of the
> > first things I monitored very closely.
>
> Now please try without conn tracking module. I saw many failures in the past
> that were trigered by conntrack.
>
> Do you have some firewall rules, using some netfilter modules like hashlimit ?

I will have to look into this.
