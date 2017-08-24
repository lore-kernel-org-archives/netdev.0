From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/2] Add software rx timestamp for TCP.
Date: Wed, 23 Aug 2017 20:32:59 -0700 (PDT)
Message-ID: <20170823.203259.203702773602223523.davem@davemloft.net>
References: <20170822210849.23162-1-maloneykernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemdebruijn.kernel@gmail.com,
        soheil@google.com, maloney@google.com
To: maloneykernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58144 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751062AbdHXDdA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 23:33:00 -0400
In-Reply-To: <20170822210849.23162-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloneykernel@gmail.com>
Date: Tue, 22 Aug 2017 17:08:47 -0400

> From: Mike Maloney <maloney@google.com>
> 
> Add software rx timestamps for TCP, and a test to ensure consistency of
> behavior between IP, UDP, and TCP implementation.
> 
> Changes since v1:
>   -Initialize tss->ts[1] to 0 if caller requested any timestamps.
>   -Fix test case to validate that tss->ts[1] is zero.
>   -Fix tests to actually use a raw socket.
>   -Fix --tcp flag to work on the test.

Series applied, thanks.
