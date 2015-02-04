From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net v3] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 4 Feb 2015 20:05:32 +0900
Message-ID: <CAKD1Yr0EaSzdoK7xicwSWaJzF6Rii76D_9YBugGMyUTcQdOGDg@mail.gmail.com>
References: <1422859156-30691-1-git-send-email-ek@google.com>
 <CAKD1Yr0k44kwwtfWN-t9C1f7WKT0o=yimPwbfLtBnnvUvXrm=w@mail.gmail.com>
 <CAAedzxoF2gJit1e05UJSOWX2RJwbA1PSbdABK3zgta-XtajJyw@mail.gmail.com>
 <CAKD1Yr18AvHChpSJau5O2GypDRZ39sGaDfnjV4f73C77gYCXVw@mail.gmail.com> <CAAedzxptQEX+c+khEmO7QvU+58+3W+iuOJ3O9zBfuWbWjFkakw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:50320 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932892AbbBDLFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 06:05:54 -0500
Received: by mail-ie0-f173.google.com with SMTP id tr6so1097690ieb.4
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 03:05:54 -0800 (PST)
In-Reply-To: <CAAedzxptQEX+c+khEmO7QvU+58+3W+iuOJ3O9zBfuWbWjFkakw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 7:54 PM, Erik Kline <ek@google.com> wrote:
>                 if (flags_testing && etc) { unlock; return 1; }
>                 else break;

Oh, I see. I suppose it's possible to fail early if strict == 1, yes.
AIUI it's not possible for the same address to be assigned twice to
the same interface with different prefix lengths (unlike IPv4, which
allows this). But it's possible for the same address to be assigned to
multiple interfaces, so you can't do it if strict == 0.
