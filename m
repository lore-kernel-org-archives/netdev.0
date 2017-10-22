From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] nfp: use struct fields for 8 bit-wide access
Date: Sun, 22 Oct 2017 03:10:44 +0100 (WEST)
Message-ID: <20171022.031044.847187692179673526.davem@davemloft.net>
References: <20171020174952.23572-1-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        oss-drivers@netronome.com, pieter.jansenvanvuuren@netronome.com
To: simon.horman@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57646 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932310AbdJVCKr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 22:10:47 -0400
In-Reply-To: <20171020174952.23572-1-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <simon.horman@netronome.com>
Date: Fri, 20 Oct 2017 19:49:52 +0200

> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> 
> Use direct access struct fields rather than PREP_FIELD()
> macros to manipulate the jump ID and length, both of which
> are exactly 8-bits wide. This simplifies the code somewhat.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>
> Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> Acked-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
