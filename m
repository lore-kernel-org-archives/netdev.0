From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH ethtool 1/5] ethtool-copy.h: sync with net
Date: Tue, 14 Apr 2015 17:34:40 +0300
Message-ID: <CAPcc5Pj7Xo0ETPzpqgjnf9tA9AeNnqOFPiPFE7XXFYSinXRsXA@mail.gmail.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
	<1422193883-30504-2-git-send-email-amirv@mellanox.com>
	<1428195613.11260.111.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Amir Vadai <amirv@mellanox.com>, netdev <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f41.google.com ([209.85.215.41]:32805 "EHLO
	mail-la0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753579AbbDNOel (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 10:34:41 -0400
Received: by layy10 with SMTP id y10so9689118lay.0
        for <netdev@vger.kernel.org>; Tue, 14 Apr 2015 07:34:40 -0700 (PDT)
In-Reply-To: <1428195613.11260.111.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Apr 5, 2015 at 4:00 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Sun, 2015-01-25 at 15:51 +0200, Amir Vadai wrote:
>> From: Eyal Grossman <eyalgr@mellanox.com>

[...]

>
> You've copied from include/uapi/linux/ethtool.h, which is not quite
> right.  The include/uapi directory contains definitions shared with
> userland, but the headers still need some processing (like removing the
> _UAPI prefix from header guards).  You should use 'make headers_install'
> to generate the userland version in usr/include/linux/ethtool.h.
Sorry, didn't know.

> Anyway, I've done that myself based on today's net tree.
Is it in your git [1] ? Because I couldn't find the updated version there.

[1] - git://git.kernel.org/pub/scm/network/ethtool/ethtool.git

Thanks,
Amir
>
> Ben.
>
> --
> Ben Hutchings
> Quantity is no substitute for quality, but it's the only one we've got.
