From: John Dykstra <john.dykstra1@gmail.com>
Subject: Re: [PATCH] tcp: tcp_prequeue() can use keyed wakeups
Date: Wed, 13 May 2009 10:05:07 -0500
Message-ID: <1242227107.7145.13.camel@Maple>
References: <4A031596.4020904@cosmosbay.com>
	 <4A031867.9060806@cosmosbay.com> <1242178490.11389.20.camel@merlyn>
	 <4A0A3E5A.6040702@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f115.google.com ([209.85.222.115]:38146 "EHLO
	mail-pz0-f115.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507AbZEMPMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 11:12:51 -0400
Received: by pzk13 with SMTP id 13so273410pzk.33
        for <netdev@vger.kernel.org>; Wed, 13 May 2009 08:12:51 -0700 (PDT)
In-Reply-To: <4A0A3E5A.6040702@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-05-13 at 05:28 +0200, Eric Dumazet wrote:

> To see a benefit of this patch, we would need two threads, one blocked
> in a recv(),
> one blocked in a send() on same socket (or a poll/epoll user with same
> bi-directional trafic)

Agreed.

  --  John

