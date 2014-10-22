From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [RFC PATCH v2 net-next] net: ipv6: Add a sysctl to make
 optimistic addresses useful candidates
Date: Wed, 22 Oct 2014 20:50:55 +0900
Message-ID: <CAKD1Yr08muZ0Dwwt5Xmi+mEFP9OBBYe9CceswsEzpm5PkMUCMg@mail.gmail.com>
References: <1413864306-20055-1-git-send-email-ek@google.com>
 <1413920743.32553.45.camel@localhost> <CAAedzxpsaEGt+oO0xJWLxcjapdRYauHP4rAsKkf_skcdzbGEmg@mail.gmail.com>
 <1413972774.2337.37.camel@localhost> <CAAedzxpG1TEVVm_kHgRJcOO7qkFmyyYnfPL0ONN7GcypmtRq1g@mail.gmail.com>
 <1413977771.2337.50.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Erik Kline <ek@google.com>, netdev <netdev@vger.kernel.org>,
	Ben Hutchings <ben@decadent.org.uk>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:40728 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932723AbaJVLvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2014 07:51:16 -0400
Received: by mail-ie0-f171.google.com with SMTP id x19so2637871ier.16
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2014 04:51:16 -0700 (PDT)
In-Reply-To: <1413977771.2337.50.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 22, 2014 at 8:36 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> In the near future we also must introduce specific DAD events needed for
> RFC7217 addresses (to count DAD progress and safe the information per
> prefix in user space). I would prefer to keep the logic for RTM_NEWADDR
> that the kernel will definitely allow the use of the address but
> RTM_NEWADDR should be handled idempotent by user space.

Duplicate RTM_NEWADDR notifications aren't a problem though, right?
The current code send RTM_NEWADDR every time an RA increases the
lifetime of an address, so I think it's reasonable to assume that apps
have to be able to deal with it, because it's pretty frequent.
