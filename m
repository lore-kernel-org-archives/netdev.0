From: Chintu Aggarwal <chintuofkpt@gmail.com>
Subject: linux xfrm question
Date: Wed, 27 Aug 2014 12:07:22 +0530
Message-ID: <CAFbuYbnotgZxbu2gKJpCdPP-efbK0pi+ZcLs6j8it3Voeoh=Tw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f195.google.com ([209.85.213.195]:61154 "EHLO
	mail-ig0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933114AbaH0GhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2014 02:37:23 -0400
Received: by mail-ig0-f195.google.com with SMTP id uq10so1607267igb.6
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 23:37:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I wanted to add multiple SAs but only one SPD. SPD has remote address
as wildcard but proper local address. SAs have both proper local and
remote address. Local address in all SAs and SPD is same. As IPsec has
to be applied for all packets, I wanted to avoid SPD setup and lookup
time.

When I use it this way, it seems that xfrm code adds bundles to the
same SPD which is a linear search. Is there a hash implementation
available for the same, or some other way to improve search time here?

Thanks
Chintu
