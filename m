From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH 2.6.22 5/5] iw_cxgb3: Update required firmware revision
	to 4.0.0.
Date: Fri, 27 Apr 2007 08:03:56 -0500
Message-ID: <1177679036.10490.15.camel@stevo-desktop>
References: <20070426202057.24234.56383.stgit@dell3.ogc.int>
	 <20070426202126.24234.71523.stgit@dell3.ogc.int>
	 <adaps5qo6hh.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, divy@chelsio.com, general@lists.openfabrics.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-71-42-183-126.sw.biz.rr.com ([71.42.183.126]:48231 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755790AbXD0ND5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Apr 2007 09:03:57 -0400
In-Reply-To: <adaps5qo6hh.fsf@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-04-26 at 20:12 -0700, Roland Dreier wrote:
>  > Update required firmware revision to 4.0.0.
> 
> Hmm... should we fold this into the earlier patch, which actually
> needs this new FW?  Or at least merge this patch first?
> 

I separated it only because cxgb3 is maintained by Jeff.  Feel free to
make it one commit.  That is the proper way IMO. But I didn't know what
SOP was for changes that hit different maintainers but are prerequisites
of each other...


> Also, is it cool with everyone to require a new FW, even for users who
> might not be using (or even building) the RDMA driver?  I'm not sure
> what a good solution would be really, so maybe the pain of forcing
> everyone to update FW is the least bad thing to do.
>  - R.

I was asked to package the firmware version change along with my rdma
changes by Divy since they didn't have any other cxgb3 changes right
now.  I believe Chelsio wants folks on this new firmware asap.


Steve.





