From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] bnx2x: Support for managing RX indirection table
Date: Tue, 15 Feb 2011 14:50:18 -0800
Message-ID: <AANLkTi=VT7BMpJZeE_gKOceNw+=Db40p3znmyt=Jc2Un@mail.gmail.com>
References: <alpine.DEB.2.00.1102150815060.27695@pokey.mtv.corp.google.com>
	<1297788529.2584.12.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, eilong@broadcom.com, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:37413 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755249Ab1BOWuW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Feb 2011 17:50:22 -0500
Received: from kpbe11.cbf.corp.google.com (kpbe11.cbf.corp.google.com [172.25.105.75])
	by smtp-out.google.com with ESMTP id p1FMoK6X025543
	for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 14:50:20 -0800
Received: from pwj8 (pwj8.prod.google.com [10.241.219.72])
	by kpbe11.cbf.corp.google.com with ESMTP id p1FMoIMd009168
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 14:50:19 -0800
Received: by pwj8 with SMTP id 8so217458pwj.22
        for <netdev@vger.kernel.org>; Tue, 15 Feb 2011 14:50:18 -0800 (PST)
In-Reply-To: <1297788529.2584.12.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>> + =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rx_indir_table=
[128];
>
> Shouldn't the dimension be TSTORM_INDIRECTION_TABLE_SIZE?
>

It's not a defined constant, so the alternative would be to malloc it
which seems like overkill to me.

Broadcom guys: are there any adapters or configuration of bnx2x where
the indirection table would be greater than 128?

Tom
