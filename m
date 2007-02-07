From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: Re: [PATCH 0/7] [S390]: Introduction of AF_IUCV sockets support
Date: Wed, 7 Feb 2007 12:36:51 +0100
Message-ID: <20070207113651.GA12915@de.ibm.com>
References: <20070202120528.GA10392@de.ibm.com> <20070206.144106.39659974.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:45054 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161222AbXBGLjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 06:39:03 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l17Bd1ef030702
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 06:39:01 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l17Bd1ib546550
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 04:39:01 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l17Bd1o5010515
	for <netdev@vger.kernel.org>; Wed, 7 Feb 2007 04:39:01 -0700
Content-Disposition: inline
In-Reply-To: <20070206.144106.39659974.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 06, 2007 at 02:41:06PM -0800, David Miller wrote:
> From: Frank Pavlic <fpavlic@de.ibm.com>
> Date: Fri, 2 Feb 2007 13:05:28 +0100
> 
> > The patch set consists of following patches:
> > 
> > [1/7] [S390]: Rewrite of the IUCV base code, part 1
> > [2/7] [S390]: Rewrite of the IUCV base code, part 2
> > [3/7] [S390]: Adapt monreader driver to new IUCV API
> > [4/7] [S390]: Adapt vmlogrdr driver to new IUCV API
> > [5/7] [S390]: Adapt netiucv driver to new IUCV API
> > [6/7] [S390]: Adapt special message interface to new IUCV API
> > [7/7] [S390]: Add AF_IUCV socket support
> 
> I have no fundamental objections to this, although I think
> I'll end up needing something similar on Niagara at some
> point :-)
I guess there are and will be more than two guys needing such a vehicle.
With all the virtualization support in Linux we have right now
and the stuff which will come in the future IMO we will need some kind
of a generic inter-communication infrastructure (what a wording :-) )
in Linux . 
> 
> The list ate the first patch due to it's size.  Could you
> email me a copy privately so can integrate all of your work
> into my net-2.6.21 tree?
> 
> Thanks.
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
