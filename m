From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 9/9 v2] net: Add sysctl to trust checksum_complete
Date: Sun, 27 Apr 2014 21:07:24 -0700
Message-ID: <CA+mtBx9w6-id5NDuP31yMrhO9Ho8TM2O5oGfneXiT_f+G+Xvag@mail.gmail.com>
References: <alpine.DEB.2.02.1404261402390.27405@tomh.mtv.corp.google.com>
	<20140426193135.7390d306@samsung-9>
	<CA+mtBx-hAJDvXigrw1w3S1OBhmG4iiZvBBKNtCXZMt+8ZzFduw@mail.gmail.com>
	<20140427.233204.1660487737838648405.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:58040 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbaD1EHZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 00:07:25 -0400
Received: by mail-ie0-f180.google.com with SMTP id at1so2677112iec.39
        for <netdev@vger.kernel.org>; Sun, 27 Apr 2014 21:07:25 -0700 (PDT)
In-Reply-To: <20140427.233204.1660487737838648405.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> If we do anything, we should do it consistently and not just for one
> specific checksum delivery type.
>
> So if we add a sysctl, it should revalidate the checksum in software
> for all checksum offload variants, and such a sysctl should be off by
> default.

Okay, but I would want to add a new checksum type to distinguish
checksum_complete that was done in software as opposed to one received
from a device. I was planning on doing this in a later patch set. I
suppose you can disregard this patch for now.
