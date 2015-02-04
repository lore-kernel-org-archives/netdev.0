From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net v3] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 4 Feb 2015 19:47:19 +0900
Message-ID: <CAKD1Yr18AvHChpSJau5O2GypDRZ39sGaDfnjV4f73C77gYCXVw@mail.gmail.com>
References: <1422859156-30691-1-git-send-email-ek@google.com>
 <CAKD1Yr0k44kwwtfWN-t9C1f7WKT0o=yimPwbfLtBnnvUvXrm=w@mail.gmail.com> <CAAedzxoF2gJit1e05UJSOWX2RJwbA1PSbdABK3zgta-XtajJyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:61299 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965433AbbBDKrm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 05:47:42 -0500
Received: by mail-ie0-f169.google.com with SMTP id rl12so1032922iec.0
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 02:47:41 -0800 (PST)
In-Reply-To: <CAAedzxoF2gJit1e05UJSOWX2RJwbA1PSbdABK3zgta-XtajJyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 4, 2015 at 7:38 PM, Erik Kline <ek@google.com> wrote:
> One more thing I just noticed, though: if the interface and the
> address matches the supplied arguments but we don't like the flags we
> keep on processing all other addresses on that interface I think.  Is
> that right?  (Easy to fix in a follow on patch.)

What else would the code do? It loops over all the addresses on the
system in hash table order, not interface-by-interface.
