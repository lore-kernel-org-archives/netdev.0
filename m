From: Shirley Ma <mashirle@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] vhost: Restart tx poll when socket send
 queue is full
Date: Thu, 25 Feb 2010 19:09:28 -0800
Message-ID: <1267153768.5977.1.camel@localhost.localdomain>
References: <1266526751.15681.71.camel@w-sridhar.beaverton.ibm.com>
	 <20100223102437.GA23835@redhat.com>
	 <1266946292.6364.6.camel@w-sridhar.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Sridhar Samudrala <sri@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:34026 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751232Ab0CASUX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Mar 2010 13:20:23 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o21IBe9p000913
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 11:11:40 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o21IK99e125538
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 11:20:14 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o21IK8NT005711
	for <netdev@vger.kernel.org>; Mon, 1 Mar 2010 11:20:09 -0700
In-Reply-To: <1266946292.6364.6.camel@w-sridhar.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This also fixes tx hung issue between guest and guest communication
through vhost.

Thanks
Shirley

