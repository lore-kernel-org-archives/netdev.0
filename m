From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] SCTP: Remove an useless parameter from
Date: Thu, 27 Mar 2008 23:54:04 -0300
Message-ID: <20080328025404.GO14945@ghostprotocols.net>
References: <47EC4F56.6000300@cn.fujitsu.com> <20080328020754.GN14945@ghostprotocols.net> <47EC570E.5090004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>,
	vladislav <vladislav.yasevich@hp.com>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49406 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755994AbYC1Cyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 22:54:49 -0400
Content-Disposition: inline
In-Reply-To: <47EC570E.5090004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 28, 2008 at 10:25:18AM +0800, Gui Jianfeng escreveu:
> Arnaldo Carvalho de Melo wrote:
> > Em Fri, Mar 28, 2008 at 09:52:22AM +0800, Gui Jianfeng escreveu:
> >> Vlad,
> >> There is an useless parameter in sctp_cmd_hb_timer_update,
> >> remove it.
> >>
> >> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> >> ---
> >>  net/sctp/sm_sideeffect.c |    3 +--
> >>  1 files changed, 1 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> >> index 28eb38e..5daeab5 100644
> >> --- a/net/sctp/sm_sideeffect.c
> >> +++ b/net/sctp/sm_sideeffect.c
> >> @@ -593,7 +593,6 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
> >>  
> >>  /* Helper function to update the heartbeat timer. */
> >>  static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
> >> -				     struct sctp_association *asoc,
> >>  				     struct sctp_transport *t)
> >>  {
> >>  	/* Update the heartbeat timer.  */
> >> @@ -1457,7 +1456,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
> >>  
> >>  		case SCTP_CMD_HB_TIMER_UPDATE:
> >>  			t = cmd->obj.transport;
> >> -			sctp_cmd_hb_timer_update(commands, asoc, t);
> >> +			sctp_cmd_hb_timer_update(commands, t);
> >>  			break;
> > 
> > you mean it was not compiling before?
> 
>   I mean this parameter is never used in this function.

Sorry for the disturbance, you're of course right.

- Arnaldo
