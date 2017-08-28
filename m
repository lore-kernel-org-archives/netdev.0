From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] fix layer calculation and flow dissector use
Date: Mon, 28 Aug 2017 15:20:39 -0700 (PDT)
Message-ID: <20170828.152039.355601879528108819.davem@davemloft.net>
References: <1503682263-17858-1-git-send-email-pieter.jansenvanvuuren@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        simon.horman@netronome.com, jakub.kicinski@netronome.com
To: pieter.jansenvanvuuren@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49716 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751213AbdH1WUl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:20:41 -0400
In-Reply-To: <1503682263-17858-1-git-send-email-pieter.jansenvanvuuren@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
Date: Fri, 25 Aug 2017 19:31:00 +0200

> Previously when calculating the supported key layers MPLS, IPv4/6
> TTL and TOS were not considered. Formerly flow dissectors were referenced
> without first checking that they are in use and correctly populated by TC.
> Additionally this patch set fixes the incorrect use of mask field for vlan
> matching.

Series applied, thanks.
