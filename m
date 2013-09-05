From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] pkt_sched: fq: Fair Queue packet scheduler
Date: Wed, 04 Sep 2013 20:41:19 -0700
Message-ID: <1378352479.11205.5.camel@edumazet-glaptop>
References: <1377816595.8277.54.camel@edumazet-glaptop>
	   <5226C4A0.6040709@redhat.com> <1378274376.7360.82.camel@edumazet-glaptop>
	  <5226D39C.9070401@redhat.com> <1378290638.7360.85.camel@edumazet-glaptop>
	 <5227F57D.7030709@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Yuchung Cheng <ycheng@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:33016 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752871Ab3IEDlV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 23:41:21 -0400
Received: by mail-pb0-f48.google.com with SMTP id ma3so1202150pbc.7
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 20:41:20 -0700 (PDT)
In-Reply-To: <5227F57D.7030709@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-05 at 11:07 +0800, Jason Wang wrote:

> tc -s -d qdisc
> qdisc fq 8001: dev eth0 root refcnt 2 [Unknown qdisc, optlen=64]
>  Sent 6680760347 bytes 4431855 pkt (dropped 0, overlimits 0 requeues 0)
>  backlog 0b 0p requeues 0
> 
> btw, is the fq support for tc merged into iproute2? Looks like I can't
> find them.

Yep its there on net-next-3.11 branch

# git branch -a
  master
* net-next-3.11
  remotes/origin/HEAD -> origin/master
  remotes/origin/iproute-3.5.1
  remotes/origin/master
  remotes/origin/net-next-3.11

# cat .git/config 
[core]
	repositoryformatversion = 0
	filemode = true
	bare = false
	logallrefupdates = true
[remote "origin"]
	url = git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
	fetch = +refs/heads/*:refs/remotes/origin/*
[branch "master"]
	remote = origin
	merge = refs/heads/master
[branch "net-next-3.11"]
	remote = origin
	merge = refs/heads/net-next-3.11
