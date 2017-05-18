From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: make struct dst_entry::dev first member
Date: Thu, 18 May 2017 10:30:50 -0400 (EDT)
Message-ID: <20170518.103050.1538447500415809763.davem@davemloft.net>
References: <20170517163138.GA5269@avx2>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754467AbdEROav (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 10:30:51 -0400
In-Reply-To: <20170517163138.GA5269@avx2>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Wed, 17 May 2017 19:31:39 +0300

> struct dst_entry::dev is used most often. Move it so it can be
> accessed without imm8 offset on x86_64.
 ...
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
