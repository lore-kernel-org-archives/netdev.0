From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 1/2] vhost: allow multiple workers threads
Date: Mon, 20 Feb 2012 17:04:10 -0800
Message-ID: <1329786250.13141.9.camel@localhost.localdomain>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>
	 <1329519726-25763-2-git-send-email-aliguori@us.ibm.com>
	 <20120219144145.GA16620@redhat.com>
	 <OFC071CE44.FE2F733D-ON862579AA.0055FCA0-862579AA.0057082B@us.ibm.com>
	 <20120220192708.GA18308@redhat.com> <4F42A2FB.7000501@us.ibm.com>
	 <20120220210005.GA19278@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <aliguori@us.ibm.com>,
	Tom Lendacky <toml@us.ibm.com>, netdev@vger.kernel.org,
	Cristian Viana <vianac@br.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:47316 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754932Ab2BUBES (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 20:04:18 -0500
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Mon, 20 Feb 2012 18:04:18 -0700
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id DFB59C90052
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 20:04:14 -0500 (EST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1L14Ewg250110
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 20:04:15 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1L14DaB011400
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 23:04:14 -0200
In-Reply-To: <20120220210005.GA19278@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-02-20 at 23:00 +0200, Michael S. Tsirkin wrote:
> 
> The point was really to avoid scheduler overhead
> as with tcp, tx and rx tend to run on the same cpu.

We have tried different approaches in the past, like splitting vhost
thread to separate TX, RX threads; create per cpu vhost thread instead
of creating per VM per virtio_net vhost thread... 

We think per cpu vhost thread is a better approach based on the data we
have collected. It will reduce both vhost resource and scheduler
overhead. It will not depend on host scheduler, has less various. The
patch is under testing, we hope we can post it soon.

Thanks
Shirley
