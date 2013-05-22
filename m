From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: question on pktgen shutdown logic.
Date: Wed, 22 May 2013 16:35:49 -0700
Message-ID: <1369265749.3301.372.camel@edumazet-glaptop>
References: <519D519B.8040406@candelatech.com>
	 <1369264921.3301.370.camel@edumazet-glaptop>
	 <519D54A8.4090707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:46301 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756285Ab3EVXfx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 19:35:53 -0400
Received: by mail-ob0-f179.google.com with SMTP id ta14so1994517obb.10
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 16:35:52 -0700 (PDT)
In-Reply-To: <519D54A8.4090707@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-22 at 16:28 -0700, Ben Greear wrote:

> Ahh, so it waits for the pktgen_thread_worker method to return?
> 
> Why do we bother with the pktgen_exiting flag at all...it
> would seem that just checking kthread_should_stop() would
> do the trick?

If you have 4096 cpus, setting pktgen_exiting permits all pktgen exiting
faster.

Otherwise you wait about 400 seconds (4096 * HZ/10)
