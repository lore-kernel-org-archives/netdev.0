From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 1/1] bridge: turn off carrier when the bridge is created
Date: Tue, 10 Mar 2015 22:26:34 -0700
Message-ID: <20150310222634.0e485497@urahara>
References: <1425971382-14177-1-git-send-email-Yanjun.Zhu@windriver.com>
	<1425971382-14177-2-git-send-email-Yanjun.Zhu@windriver.com>
	<54FFAAF9.3000207@windriver.com>
	<20150311.000350.315385397499592379.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Yanjun.Zhu@windriver.com, netdev@vger.kernel.org, dsahern@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:42195 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770AbbCKF0k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 01:26:40 -0400
Received: by pdbfl12 with SMTP id fl12so8202330pdb.9
        for <netdev@vger.kernel.org>; Tue, 10 Mar 2015 22:26:40 -0700 (PDT)
In-Reply-To: <20150311.000350.315385397499592379.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Mar 2015 00:03:50 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: yzhu1 <Yanjun.Zhu@windriver.com>
> Date: Wed, 11 Mar 2015 10:39:53 +0800
> 
> > Hi, Stephen && David
> > 
> > Any comment?
> 
> Asking Stephen to look at this more times will not make him respond
> any faster.  I see your posting, he sees it, everyone sees it.
> 
> If he's too busy to look into this, that's just the state of affairs
> right now and you just need to be patient.
> 
> Thanks.

This was discussed and changed long ago (before git was used).
Initially in 2.5 the bridge carrier was changed to work as you have
described but this broke some user. Therefore it was decided that the
best thing to do was keep the carrier always on for the bridge.

You might be able to find the commit by using one of the kernel
ancient history git trees. Kernel archeology is fun but 
too time consuming for me to bother with.
