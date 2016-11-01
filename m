From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] unix: escape all null bytes in abstract unix domain
 socket
Date: Tue, 01 Nov 2016 12:15:33 -0400 (EDT)
Message-ID: <20161101.121533.1036644431036762336.davem@davemloft.net>
References: <1477960895-1062-1-git-send-email-iboukris@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: iboukris@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47344 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751086AbcKAQPf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 12:15:35 -0400
In-Reply-To: <1477960895-1062-1-git-send-email-iboukris@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Isaac Boukris <iboukris@gmail.com>
Date: Tue,  1 Nov 2016 02:41:35 +0200

> Abstract unix domain socket may embed null characters,
> these should be translated to '@' when printed out to
> proc the same way the null prefix is currently being
> translated.
> 
> This helps for tools such as netstat, lsof and the proc
> based implementation in ss to show all the significant
> bytes of the name (instead of getting cut at the first
> null occurrence).
> 
> Signed-off-by: Isaac Boukris <iboukris@gmail.com>

Applied, thank you.
