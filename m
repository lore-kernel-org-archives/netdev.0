From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH] net: change capability used by socket options IP{,V6}_TRANSPARENT
Date: Mon, 17 Oct 2011 15:19:51 -0700
Message-ID: <CANP3RGde3Rsv2HrptywtgPbN5-Vk34O3T2ZN5bte8OHhGUxBwg@mail.gmail.com>
References: <20110920.154213.888729603269720228.davem@redhat.com>
	<1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Balazs Scheidler <bazsi@balabit.hu>
To: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:31370 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754371Ab1JQWTy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:19:54 -0400
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id p9HMJrKw005193
	for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 15:19:53 -0700
Received: from pzk1 (pzk1.prod.google.com [10.243.19.129])
	by hpaq2.eem.corp.google.com with ESMTP id p9HMDZ7Q022229
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 15:19:52 -0700
Received: by pzk1 with SMTP id 1so6799829pzk.5
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 15:19:51 -0700 (PDT)
In-Reply-To: <1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I still think we need a more precise permission for this, but possibly
not quite as specific as a separate capability just for transparent.
Maybe RAW should be split into RAW_READ (eavesdropping) and RAW_WRITE (=
spoof).

Either way, I'll leave that for another day.

--=20
Maciej A. =C5=BBenczykowski
Kernel Networking Developer @ Google
