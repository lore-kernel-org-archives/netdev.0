From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCHSET] printk, netconsole: implement reliable netconsole
Date: Tue, 21 Apr 2015 14:51:28 -0700
Message-ID: <20150421145128.4354fd41@urahara>
References: <1429225433-11946-1-git-send-email-tj@kernel.org>
	<201504180035.AIJ09349.SOFFHFtLOOQVMJ@I-love.SAKURA.ne.jp>
	<20150417162826.GB16743@htj.duckdns.org>
	<20150417.131712.1245246947203158168.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, penguin-kernel@I-love.SAKURA.ne.jp,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:32849 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964823AbbDUVvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 17:51:25 -0400
Received: by pdbnk13 with SMTP id nk13so254038462pdb.0
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 14:51:24 -0700 (PDT)
In-Reply-To: <20150417.131712.1245246947203158168.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Apr 2015 13:17:12 -0400 (EDT)
David Miller <davem@davemloft.net> wrote:

> From: Tejun Heo <tj@kernel.org>
> Date: Fri, 17 Apr 2015 12:28:26 -0400
> 
> > On Sat, Apr 18, 2015 at 12:35:06AM +0900, Tetsuo Handa wrote:
> >> If the sender side can wait for retransmission, why can't we use
> >> userspace programs (e.g. rsyslogd)?
> > 
> > Because the system may be oopsing, ooming or threshing excessively
> > rendering the userland inoperable and that's exactly when we want
> > those log messages to be transmitted out of the system.
> 
> If userland cannot run properly, it is almost certain that neither will
> your complex reliability layer logic.
> 
> I tend to agree with Tetsuo, that in-kernel netconsole should remain
> as simple as possible and once it starts to have any smarts and less
> trivial logic the job belongs in userspace.

Keep existing netconsole as simple as possible. It is not meant as
reliable, secure logging.

"Those who do not understand TCP are doomed to reinvent it"
