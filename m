From: Tom Herbert <therbert@google.com>
Subject: Re: small RPS cache for fragments?
Date: Tue, 17 May 2011 14:27:10 -0700
Message-ID: <BANLkTin3hRwB39LGfOSxet61Cdm3F1MsKg@mail.gmail.com>
References: <20110517.143342.1566027350038182221.davem@davemloft.net>
	<BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	<20110517.164929.1737248436066795381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:53793 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932296Ab1EQV1N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:27:13 -0400
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id p4HLRCn4012956
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:27:12 -0700
Received: from yia27 (yia27.prod.google.com [10.243.65.27])
	by kpbe18.cbf.corp.google.com with ESMTP id p4HLPueg011065
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:27:11 -0700
Received: by yia27 with SMTP id 27so424993yia.5
        for <netdev@vger.kernel.org>; Tue, 17 May 2011 14:27:11 -0700 (PDT)
In-Reply-To: <20110517.164929.1737248436066795381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Actually, I think it won't work. =A0Even Linux emits fragments last t=
o
> first, so we won't see the UDP header until the last packet where it'=
s
> no longer useful.
>
I remember observing this a while back, what's the rationale for it?

> Back to the drawing board. :-/
>
