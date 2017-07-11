From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net-next: Fix minor code bug in timestamping.txt
Date: Tue, 11 Jul 2017 13:35:14 -0700 (PDT)
Message-ID: <20170711.133514.1211086377571475842.davem@davemloft.net>
References: <20170708192844.70105-1-ahmad@a3f.at>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ahmad@a3f.at
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41632 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753958AbdGKUfP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Jul 2017 16:35:15 -0400
In-Reply-To: <20170708192844.70105-1-ahmad@a3f.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ahmad Fatoum <ahmad@a3f.at>
Date: Sat,  8 Jul 2017 21:28:44 +0200

> Passing (void*)val instead of &val would make a pointer out of an integer
> and cause sock_setsockopt to -EFAULT.
> 
> See tools/testing/selftests/networking/timestamping/timestamping.c
> for a working example.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Ahmad Fatoum <ahmad@a3f.at>

Applied.
