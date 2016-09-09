From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] nfp: fixes and trivial cleanup
Date: Thu, 08 Sep 2016 17:18:57 -0700 (PDT)
Message-ID: <20160908.171857.762759573997622959.davem@davemloft.net>
References: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42888 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750760AbcIIAS6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 20:18:58 -0400
In-Reply-To: <1473273937-9230-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed,  7 Sep 2016 19:45:34 +0100

> First patch drops unnecessary version.h includes.  Second one
> drops support for pre-release versions of FW ABI.  Removing
> FW ABI 0.0 from supported set is particularly good since 0
> could just be uninitialized memory.  Last but not least I drop
> unnecessary padding of frames on RX which makes us count bytes
> incorrectly for the VF2VF traffic.

Series applied, thanks.
