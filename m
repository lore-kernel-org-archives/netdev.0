From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] macvlan: add offload features for
 encapsulation
Date: Fri, 18 Aug 2017 16:07:04 -0700 (PDT)
Message-ID: <20170818.160704.891753130267144975.davem@davemloft.net>
References: <20170816213446.10584-1-dmichail@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dmichail@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34538 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751671AbdHRXHF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:07:05 -0400
In-Reply-To: <20170816213446.10584-1-dmichail@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dmichail@google.com>
Date: Wed, 16 Aug 2017 14:34:46 -0700

> Currently macvlan devices do not set their hw_enc_features making
> encapsulated Tx packets resort to SW fallbacks. Add encapsulation GSO
> offloads to ->features as is done for the other GSOs and set
> ->hw_enc_features.
> 
> Signed-off-by: Dimitris Michailidis <dmichail@google.com>

Applied.
