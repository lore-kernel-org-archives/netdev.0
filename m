From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next 3/3] net/core/sock.c: sk_clone_lock()
 should only do get_net() if the parent is not a kernel socket
Date: Thu, 30 Jul 2015 23:31:58 +0200
Message-ID: <1438291918.20182.135.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1438245718.git.sowmini.varadhan@oracle.com>
	 <15334c31275787177fb1d12927604ee87d3938d4.1438245718.git.sowmini.varadhan@oracle.com>
	 <1438261607.20182.130.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAHA+R7N7kF9=qACWrnfpR2N5F+nbmnZTvA9+c79x7-RFX5Aang@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev <netdev@vger.kernel.org>,
	ajaykumar.hotchandani@oracle.com,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f194.google.com ([209.85.212.194]:36244 "EHLO
	mail-wi0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752225AbbG3VcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2015 17:32:03 -0400
Received: by wilh8 with SMTP id h8so1306047wil.3
        for <netdev@vger.kernel.org>; Thu, 30 Jul 2015 14:32:01 -0700 (PDT)
In-Reply-To: <CAHA+R7N7kF9=qACWrnfpR2N5F+nbmnZTvA9+c79x7-RFX5Aang@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-30 at 11:29 -0700, Cong Wang wrote:
> On Thu, Jul 30, 2015 at 6:06 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> > CC Eric Biederman
> >
> > It looks this should be submitted for 'net' tree, not 'net-next'
> >
> 
> It only affects TCP kernel sockets, and we only have few use cases in tree,
> and it looks like dlm does its own ->accpet(), so net-next should be fine.

Right, nobody uses NFS anymore I guess.

If bug was added in 4.2, fix should land in net tree.

Not sure why we should wait.
