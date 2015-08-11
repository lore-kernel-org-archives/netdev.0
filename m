From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] tcp: reduce cpu usage under tcp memory
 pressure when SO_SNDBUF is set
Date: Tue, 11 Aug 2015 07:49:36 -0700
Message-ID: <1439304576.1084.24.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150811143846.672A92039@prod-mail-relay10.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Jason Baron <jbaron@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:34081 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964954AbbHKOtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2015 10:49:39 -0400
Received: by pdbfa8 with SMTP id fa8so44187284pdb.1
        for <netdev@vger.kernel.org>; Tue, 11 Aug 2015 07:49:38 -0700 (PDT)
In-Reply-To: <20150811143846.672A92039@prod-mail-relay10.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-08-11 at 14:38 +0000, Jason Baron wrote:
> From: Jason Baron <jbaron@akamai.com>

> In my testing, this brought a single threaad's cpu usage down from 100% to ~1%
> while maintaining the same level of throughput.
> 

Hi Jason. Could you give more details on this test ?

How many flows are competing ?
