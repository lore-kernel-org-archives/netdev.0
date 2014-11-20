From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: Remove some spurious dropped packet
 profile hits from the passive connection accept path
Date: Thu, 20 Nov 2014 13:48:29 -0800
Message-ID: <1416520109.8629.44.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20141120185829.986CB290095D@tardy>
	 <1416516423.8629.43.camel@edumazet-glaptop2.roam.corp.google.com>
	 <546E5DAF.5090907@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <raj@tardy.usa.hp.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f173.google.com ([209.85.223.173]:46247 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757086AbaKTVsc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 16:48:32 -0500
Received: by mail-ie0-f173.google.com with SMTP id y20so3692279ier.18
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 13:48:31 -0800 (PST)
In-Reply-To: <546E5DAF.5090907@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-11-20 at 13:31 -0800, Rick Jones wrote:

> Do you mean when there is actually data in the SYN?

No, I mean the packet can be _dropped_ here, really.

SYN flood for example.
