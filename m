From: David Miller <davem@davemloft.net>
Subject: Re: Minimum MTU Mess
Date: Tue, 06 Sep 2016 16:55:29 -0700 (PDT)
Message-ID: <20160906.165529.496766310703537877.davem@davemloft.net>
References: <20160902170742.GA17677@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56914 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755032AbcIFXza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Sep 2016 19:55:30 -0400
In-Reply-To: <20160902170742.GA17677@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>
Date: Fri, 2 Sep 2016 13:07:42 -0400

> In any case, the number of "mtu < 68" and "#define FOO_MIN_MTU 68", or
> variations thereof, under drivers/net/ is kind of crazy.

Agreed, we can have a default and let the different cases provide
overrides.

Mostly what to do here is a function of the hardware though.
