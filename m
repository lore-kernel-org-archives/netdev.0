From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] ipv6: Fix dst_release of invalid pointer
Date: Wed, 27 Jan 2010 13:29:23 +0530
Message-ID: <OFDF32D710.F6D035E8-ON652576B8.002A584E-652576B8.002AC8E6@in.ibm.com>
References: <20100127070802.26065.73104.sendpatchset@krkumar2.in.ibm.com> <20100126.231133.165423271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp08.in.ibm.com ([122.248.162.8]:33743 "EHLO
	e28smtp08.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751393Ab0A0HrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2010 02:47:25 -0500
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp08.in.ibm.com (8.14.3/8.13.1) with ESMTP id o0R7BZwu001975
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 12:41:35 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o0R7lMCj2191418
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 13:17:23 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o0R7lM0c018692
	for <netdev@vger.kernel.org>; Wed, 27 Jan 2010 13:17:22 +0530
In-Reply-To: <20100126.231133.165423271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 01/27/2010 12:41:33 PM:

> From: Krishna Kumar <krkumar2@in.ibm.com>
> Date: Wed, 27 Jan 2010 12:38:02 +0530
>
> > Fix dst_release on a invalid region.
> >
> > Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
>
> NULL, is NULL, is NULL, and always will be NULL.
>
> Even if rt == NULL, &rt->u.dst will be NULL too.
>
> So it's just plain NULL.
>
> You NULL that? :-)

Yes :)

I forgot dst_entry was the first element in rt6_info.

thanks,

- KK

