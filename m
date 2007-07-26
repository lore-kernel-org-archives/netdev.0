From: Joy Latten <latten@austin.ibm.com>
Subject: Re: [PATCH]: 2nd revision of make xfrm_audit_log more generic
Date: Thu, 26 Jul 2007 16:12:15 -0500
Message-ID: <1185484335.15699.472.camel@faith.austin.ibm.com>
References: <200707251921.l6PJLhxV015256@faith.austin.ibm.com>
	 <20070725.171723.45714101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com, sgrubb@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:51904 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763417AbXGZVO0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Jul 2007 17:14:26 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l6QLEP4x027001
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 17:14:25 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l6QLEPZS558048
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 17:14:25 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6QLEPsd012100
	for <netdev@vger.kernel.org>; Thu, 26 Jul 2007 17:14:25 -0400
In-Reply-To: <20070725.171723.45714101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-07-25 at 17:17 -0700, David Miller wrote:
> From: Joy Latten <latten@austin.ibm.com>
> Date: Wed, 25 Jul 2007 14:21:43 -0500
> 
> > This is 2nd revision of patch to modify xfrm_audit_log() such
> > that it can accomodate auditing other ipsec events
> > besides add/delete of an SA or SPD entry.
> > 
> > 2nd revision includes new define for all IPsec
> > events in audit.h and introduces "op=" entry
> > in logfile as well as add a hyphen in description
> > for report parsing. 
> > 
> > This is a small change to accomodate updating
> > ipsec protocol to RFCs 4301, 4302 and 4303 which
> > require auditing some ipsec events if auditing
> > is available. Please let me know if ok.
> > 
> > Signed-off-by: Joy Latten <latten@austin.ibm.com>
> 
> I like very much how the implementation of xfrm_audit_log() got
> simplified.
> 
> But _TEN_ function call arguments, good grief!
> 
> That's at least twice as many as most cpus can pass in registers.
> 
:-) :-) Sorry. Must have been in a fog or something now that I take a
step back and look at it. 
 
> Let's try an alternative where you have specialized
> xfrm_audit_log_foo() routines that take a user policy pointer, or
> whatever the main object is.
> 
> If internally this just unpacks the needed bits and calls some
> do_xfrm_audit_log() thing inside of the auditing code that takes lots
> of arguments, that's fine, but let's not expand all of that argument
> setup code in the main IPSEC code paths.

Fixing up right now. Will re-post when done.
Thanks!

Joy
