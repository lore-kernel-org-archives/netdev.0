From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH 2/2] vhost-net: add a spin_threshold parameter
Date: Tue, 21 Feb 2012 03:09:06 -0800
Message-ID: <1329822546.4407.1.camel@localhost.localdomain>
References: <1329519726-25763-1-git-send-email-aliguori@us.ibm.com>
	 <1329519726-25763-3-git-send-email-aliguori@us.ibm.com>
	 <20120219145100.GB16620@redhat.com>
	 <1329788131.13141.14.camel@localhost.localdomain>
	 <4F432CDC.4090107@redhat.com>
	 <1329805716.24119.3.camel@localhost.localdomain>
	 <4F433BD5.1070400@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Anthony Liguori <aliguori@us.ibm.com>, netdev@vger.kernel.org,
	Tom Lendacky <toml@us.ibm.com>,
	Cristian Viana <vianac@br.ibm.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:54652 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752583Ab2BUQJV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Feb 2012 11:09:21 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Tue, 21 Feb 2012 11:09:20 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 270FA6E805C
	for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 11:09:18 -0500 (EST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1LG9EP8321888
	for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 11:09:14 -0500
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1LG9MRK028863
	for <netdev@vger.kernel.org>; Tue, 21 Feb 2012 09:09:23 -0700
In-Reply-To: <4F433BD5.1070400@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-21 at 14:38 +0800, Jason Wang wrote:
> Not sure whether it's related but did you try to disable the nagle 
> algorithm during the test?

UDP doesn't use nagle, TCP_RRs results had no difference disable/enable
nagle algorithm.

Thanks
Shirley
