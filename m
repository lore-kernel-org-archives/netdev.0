From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] nfp: refuse offloading filters that redirects to
 upper devices
Date: Thu, 26 Oct 2017 10:09:06 +0900 (KST)
Message-ID: <20171026.100906.356711178165834262.davem@davemloft.net>
References: <20171025184705.4336-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        pieter.jansenvanvuuren@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55944 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdJZBJL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:09:11 -0400
In-Reply-To: <20171025184705.4336-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Wed, 25 Oct 2017 11:47:05 -0700

> From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> 
> Previously we did not ensure that a netdev is a representative netdev
> before dereferencing its private data. This can occur when an upper netdev
> is created on a representative netdev. This patch corrects this by first
> ensuring that the netdev is a representative netdev before using it.
> Checking only switchdev_port_same_parent_id is not sufficient to ensure
> that we can safely use the netdev. Failing to check that the netdev is also
> a representative netdev would result in incorrect dereferencing.
> 
> Fixes: 1a1e586f54bf ("nfp: add basic action capabilities to flower offloads")
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>

Applied and queued up for -stable.
