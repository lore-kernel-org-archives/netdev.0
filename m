From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] vhost-net: add a spin_threshold parameter
Date: Mon, 20 Feb 2012 17:35:31 -0800
Message-ID: <1329788131.13141.14.camel@localhost.localdomain>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>
	 <1329519726-25763-3-git-send-email-aliguori@us.ibm.com>
	 <20120219145100.GB16620@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <aliguori@us.ibm.com>, netdev@vger.kernel.org,
	Tom Lendacky <toml@us.ibm.com>,
	Cristian Viana <vianac@br.ibm.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:53721 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751103Ab2BUBfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2012 20:35:39 -0500
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Mon, 20 Feb 2012 18:35:38 -0700
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 762313E40048
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 18:35:36 -0700 (MST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1L1Zalj111850
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 18:35:36 -0700
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1L1ZZ67029796
	for <netdev@vger.kernel.org>; Mon, 20 Feb 2012 18:35:36 -0700
In-Reply-To: <20120219145100.GB16620@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We tried similar approach before by using a minimum timer for handle_tx
to stay in the loop to accumulate more packets before enabling the guest
notification. It did have better TCP_RRs, UDP_RRs results. However, we
think this is just a debug patch. We really need to understand why
handle_tx can't see more packets to process for multiple instances
request/response type of workload first. Spinning in this loop is not a
good solution.

Thanks
Shirley
