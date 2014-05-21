From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [RFC] Support for Multipath TCP in the Linux kernel
Date: Wed, 21 May 2014 15:32:39 +0200
Message-ID: <CAPh34mdxaQ94RxAMEDpDx5Zp3gpjipO+tr_4yC-rOTq2k2TZZw@mail.gmail.com>
References: <CAE1zot+kBdDbYrZ9m2oCg12yUBAZvToPeDeB4aZmD65xg4e0Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Christoph Paasch <christoph.paasch@uclouvain.be>
To: Octavian Purdila <octavian.purdila@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f181.google.com ([209.85.128.181]:41872 "EHLO
	mail-ve0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751022AbaEUNck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 09:32:40 -0400
Received: by mail-ve0-f181.google.com with SMTP id pa12so2455982veb.40
        for <netdev@vger.kernel.org>; Wed, 21 May 2014 06:32:40 -0700 (PDT)
In-Reply-To: <CAE1zot+kBdDbYrZ9m2oCg12yUBAZvToPeDeB4aZmD65xg4e0Cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IMHO, continue with 1) but try hard to reduce crossovers. MPTCP
specific functionality should be separated as possible and crossovers
(e.g. function calls) within standard TCP should be reduced to a bare
minimum. Fast paths should probably further optimized with static keys
(probability that a MPTCP socket is used is low - optimize for the
common case).

My two cents

[1] https://www.kernel.org/doc/Documentation/static-keys.txt
