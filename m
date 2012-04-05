From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [RFC PATCH 0/1] NUMA aware scheduling per cpu vhost thread
 patch
Date: Thu, 05 Apr 2012 09:48:43 -0700
Message-ID: <1333644523.6061.24.camel@oc3660625478.ibm.com>
References: <1332460109.7730.18.camel@oc3660625478.ibm.com>
	 <4F7191ED.80402@redhat.com> <1332870183.6496.31.camel@oc3660625478.ibm.com>
	 <20120405122824.GB31982@redhat.com>
	 <1333639327.6061.20.camel@oc3660625478.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jason Wang <jasowang@redhat.com>, netdev@vger.kernel.org,
	kvm@vger.kernel.org, tahm@linux.vnet.ibm.com, vivek@us.ibm.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:47382 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753383Ab2DEQtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Apr 2012 12:49:20 -0400
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <mashirle@us.ibm.com>;
	Thu, 5 Apr 2012 10:49:19 -0600
In-Reply-To: <1333639327.6061.20.camel@oc3660625478.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-04-05 at 08:22 -0700, Shirley Ma wrote:

> Haven't had time to focus on single stream result yet. 

I forgot to mention that if I switch the vhost scheduling to per-device
based from per vq based, this minor single stream test regression will
be gone. However the improvement of tcp_rrs, udp_rrs and other stream
case performance will also gone.

Shirley
