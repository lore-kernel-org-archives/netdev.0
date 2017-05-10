From: David Miller <davem@davemloft.net>
Subject: Re: bpf pointer alignment validation
Date: Wed, 10 May 2017 11:57:20 -0400 (EDT)
Message-ID: <20170510.115720.1396306489898364855.davem@davemloft.net>
References: <20170510055735.hfkoh4w3xaka5yl5@ast-mbp>
        <20170510.113357.362211347006868605.davem@davemloft.net>
        <59133716.7060800@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, ast@fb.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41440 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753857AbdEJP5Z (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 11:57:25 -0400
In-Reply-To: <59133716.7060800@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Wed, 10 May 2017 17:51:50 +0200

> Would probably be good nevertheless to have this as a flag for
> program loads, which gets then passed through to the verifier to
> explicitly enable strict alignment checks.
> 
> Might certainly aide developing & testing programs on archs with
> efficient unaligned access and later actually running them on archs
> that don't have it. (And at minimum, it also helps for checking
> the test suite against the verifier.)

Ok, I can implement this flag.

The only question is where to put it?  An unused bit in the program
type? :-)
