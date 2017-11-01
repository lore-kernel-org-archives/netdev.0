From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sit: Update lookup to handle links set
 to L3 slave
Date: Wed, 01 Nov 2017 12:36:22 +0900 (KST)
Message-ID: <20171101.123622.1127186739634300206.davem@davemloft.net>
References: <1509383237-26987-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45014 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751390AbdKADg0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 23:36:26 -0400
In-Reply-To: <1509383237-26987-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Mon, 30 Oct 2017 10:07:17 -0700

> Using SIT tunnels with VRFs works fine if the underlay device is in a
> VRF and the link parameter is set to the VRF device. e.g.,
> 
>     ip tunnel add jtun mode sit remote <addr> local <addr> dev myvrf
> 
> Update the device check to allow the link to be the enslaved device as
> well. e.g.,
> 
>     ip tunnel add jtun mode sit remote <addr> local <addr> dev eth4
> 
> where eth4 is enslaved to myvrf.
> 
> Reported-by: Jeff Barnhill <0xeffeff@gmail.com>
> Signed-off-by: David Ahern <dsahern@gmail.com>

Applied.
