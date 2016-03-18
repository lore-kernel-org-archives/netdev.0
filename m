From: "Evgeny Cherkashin" <Eugene.Crosser@ru.ibm.com>
Subject: Re: [PATCH] qeth: Default to allow promiscuous mode
Date: Fri, 18 Mar 2016 13:07:34 +0000
Message-ID: <201603181207.u2IC7ns9030434@d06av10.portsmouth.uk.ibm.com>
References: <56EBCC28.5090500@suse.de>,<1458234085-217667-1-git-send-email-agraf@suse.de>
 <201603171752.u2HHq7hM025196@d06av11.portsmouth.uk.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org,
	heicars2@linux.vnet.ibm.com, mschwid2@linux.vnet.ibm.com,
	Ursula Braun <ubraun@linux.vnet.ibm.com>, ihno@suse.de,
	mt@suse.com, pwieczorkiewicz@suse.de,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alexander Graf <agraf@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:50193 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754108AbcCRNHz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2016 09:07:55 -0400
Received: from localhost
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <eugene.crosser@ru.ibm.com>;
	Fri, 18 Mar 2016 13:07:53 -0000
Received: from b06cxnps3074.portsmouth.uk.ibm.com (d06relay09.portsmouth.uk.ibm.com [9.149.109.194])
	by d06dlp02.portsmouth.uk.ibm.com (Postfix) with ESMTP id 92DA7414019D
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 13:07:30 +0000 (GMT)
Received: from d06av10.portsmouth.uk.ibm.com (d06av10.portsmouth.uk.ibm.com [9.149.37.251])
	by b06cxnps3074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u2ID7mvQ1376658
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 13:07:48 GMT
Received: from d06av10.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u2IC7o6i030490
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 06:07:50 -0600
Received: from d50lp02.ny.us.ibm.com (d50lp02.pok.ibm.com [146.89.104.208])
	by d06av10.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVin) with ESMTP id u2IC7ns9030434
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 18 Mar 2016 06:07:50 -0600
Received: from localhost
	by d50lp02.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <eugene.crosser@ru.ibm.com>;
	Fri, 18 Mar 2016 09:07:47 -0400
Received: from /spool/local
	by smtp.notes.na.collabserv.com with smtp.notes.na.collabserv.com ESMTP
	for <netdev@vger.kernel.org> from <eugene.crosser@ru.ibm.com>;
	Fri, 18 Mar 2016 13:07:38 -0000
In-Reply-To: <56EBCC28.5090500@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Alexander,

-----Alexander Graf <agraf@suse.de> wrote: -----

send it explicitly if that makes it move obvious, sure.
>
>> 3. The patch should probably go via the -networking maillist.
>
>Ah, get_maintainers.pl didn't list it. You may want to send a patch
>for
>the MAINTAINERS file here :).

My mistake, you've sent it to the right place.

About the nature of the patch:

- Enabling bridgeport on adaptors on which bridgeport is already used b=
y somebody else will break somebody else's operation.

- Therefore, system administrator must only enable bridgeport on adapto=
rs on which nobody else tries to use it (without coordinating with them=
).

- Making bridge_reflect_promisc enabled by default makes it impossible.

- Therefore, bridge_reflect_promisc must not be enabled by default.

(Those who enable bridge_reflect_promisc blindly on all adaptors will b=
reak their users' setup, and will have to deal with the consequences.)

Regards,

Evgeny Cherkashin / =D0=95=D0=B2=D0=B3=D0=B5=D0=BD=D0=B8=D0=B9 =D0=A7=D0=
=B5=D1=80=D0=BA=D0=B0=D1=88=D0=B8=D0=BD / Eugene Crosser (preferred)
Software Engineer, IBM Science and Technology Center, Linux on z-System=
s Development
tel. +7 495 775 8800 ext.1103, Moscow 123317, Presnenskaya emb. 10
