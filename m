From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: RFC - VXLAN port range facility
Date: Fri, 31 May 2013 08:26:14 -0400
Message-ID: <OF9DE1CF50.DAF9EEF0-ON85257B7C.0043CE0A-85257B7C.0044520B@us.ibm.com>
References: <OF673FF136.10B22631-ON85257B7B.00436301-85257B7B.0045AAB7@us.ibm.com> <20130530094141.7c125947@nehalam.linuxnetplumber.net> <OFD5BD589B.1842E46B-ON85257B7B.00610E03-85257B7B.0062F480@us.ibm.com> <CAEP_g=8MkoK3DLJNGCrQYj_X9hB9P9fjH9hrpBwqOE=0OKWGdg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e38.co.us.ibm.com ([32.97.110.159]:43519 "EHLO
	e38.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752206Ab3EaM0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 May 2013 08:26:49 -0400
Received: from /spool/local
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Fri, 31 May 2013 06:26:47 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B64633E4008E
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 06:26:00 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4VCQG0d161258
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 06:26:16 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4VCQFLM012938
	for <netdev@vger.kernel.org>; Fri, 31 May 2013 06:26:16 -0600
In-Reply-To: <CAEP_g=8MkoK3DLJNGCrQYj_X9hB9P9fjH9hrpBwqOE=0OKWGdg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jesse Gross <jesse@nicira.com> wrote on 05/31/2013 02:09:34 AM:

> On Fri, May 31, 2013 at 3:00 AM, David Stevens <dlstevens@us.ibm.com> 
wrote:
> > But I don't think there's particular advantage in splitting it up 
30,000
> > ways when 10 ways would be both practical, for binding, and spread
> > traffic to 10 flows potentially.
> 
> Most people that run large data centers think that 16 bits of entropy
> is barely sufficient. The issue is not CPUs or link aggregation but
> Clos fabrics built using ECMP.
> 

And most people running embedded systems wouldn't want to bind to
30,000 sockets by default, which is the proper way for VXLAN to
interact with UDP.

A casual user of VXLAN between a couple of small machines on ordinary
Ethernet generally won't require multiple ports at all.

I think the default case should lean towards the low end, and the
mechanisms are there to tune the high end.

                                                        +-DLS
