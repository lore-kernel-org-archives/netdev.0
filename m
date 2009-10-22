From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [Patch] sctp: remove deprecated SCTP_GET_*_OLD stuffs
Date: Thu, 22 Oct 2009 23:44:39 +0200
Message-ID: <20091022214439.GA2635@merkur.ravnborg.org>
References: <20091015082849.4605.48311.sendpatchset@localhost.localdomain> <4AE0C64A.9080400@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Amerigo Wang <amwang@redhat.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfepa.post.tele.dk ([195.41.46.235]:54681 "EHLO
	pfepa.post.tele.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755906AbZJVVog (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 17:44:36 -0400
Content-Disposition: inline
In-Reply-To: <4AE0C64A.9080400@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 22, 2009 at 04:53:30PM -0400, Vlad Yasevich wrote:
> > diff --git a/include/net/sctp/user.h b/include/net/sctp/user.h
> > index be2334a..0991f1b 100644
> > --- a/include/net/sctp/user.h
> > +++ b/include/net/sctp/user.h
> > @@ -131,14 +131,6 @@ enum sctp_optname {
> >  #define SCTP_SOCKOPT_BINDX_REM	SCTP_SOCKOPT_BINDX_REM
> >  	SCTP_SOCKOPT_PEELOFF, 	/* peel off association. */
> >  #define SCTP_SOCKOPT_PEELOFF	SCTP_SOCKOPT_PEELOFF
> > -	SCTP_GET_PEER_ADDRS_NUM_OLD, 	/* Get number of peer addresss. */
> > -#define SCTP_GET_PEER_ADDRS_NUM_OLD	SCTP_GET_PEER_ADDRS_NUM_OLD
> > -	SCTP_GET_PEER_ADDRS_OLD, 	/* Get all peer addresss. */
> > -#define SCTP_GET_PEER_ADDRS_OLD	SCTP_GET_PEER_ADDRS_OLD
> > -	SCTP_GET_LOCAL_ADDRS_NUM_OLD, 	/* Get number of local addresss. */
> > -#define SCTP_GET_LOCAL_ADDRS_NUM_OLD	SCTP_GET_LOCAL_ADDRS_NUM_OLD
> > -	SCTP_GET_LOCAL_ADDRS_OLD, 	/* Get all local addresss. */
> > -#define SCTP_GET_LOCAL_ADDRS_OLD	SCTP_GET_LOCAL_ADDRS_OLD
> >  	SCTP_SOCKOPT_CONNECTX_OLD, /* CONNECTX old requests. */
> 
> After running the regression suite against this patch I find that we can't
> remove the enum values.  Removing the enums changes the value for the remainder
> of the definitions and breaks binary compatibility for applications that use
> those trailing options.
> 
> You should be ok with removing the #defines and actual code that uses them,
> but not the enums.  You can even rename the enums, but we must preserve
> numeric ordering.

If we really depend on the actual value of an enum as in this case,
then e should assign them direct to better document this.

	Sam
