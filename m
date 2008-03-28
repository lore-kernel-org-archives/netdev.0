From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH] SCTP: Remove an useless parameter from
Date: Thu, 27 Mar 2008 23:07:54 -0300
Message-ID: <20080328020754.GN14945@ghostprotocols.net>
References: <47EC4F56.6000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vladislav <vladislav.yasevich@hp.com>,
	netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44388 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753990AbYC1CIR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 22:08:17 -0400
Content-Disposition: inline
In-Reply-To: <47EC4F56.6000300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Fri, Mar 28, 2008 at 09:52:22AM +0800, Gui Jianfeng escreveu:
> Vlad,
> There is an useless parameter in sctp_cmd_hb_timer_update,
> remove it.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
> ---
>  net/sctp/sm_sideeffect.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/net/sctp/sm_sideeffect.c b/net/sctp/sm_sideeffect.c
> index 28eb38e..5daeab5 100644
> --- a/net/sctp/sm_sideeffect.c
> +++ b/net/sctp/sm_sideeffect.c
> @@ -593,7 +593,6 @@ static void sctp_cmd_t3_rtx_timers_stop(sctp_cmd_seq_t *cmds,
>  
>  /* Helper function to update the heartbeat timer. */
>  static void sctp_cmd_hb_timer_update(sctp_cmd_seq_t *cmds,
> -				     struct sctp_association *asoc,
>  				     struct sctp_transport *t)
>  {
>  	/* Update the heartbeat timer.  */
> @@ -1457,7 +1456,7 @@ static int sctp_cmd_interpreter(sctp_event_t event_type,
>  
>  		case SCTP_CMD_HB_TIMER_UPDATE:
>  			t = cmd->obj.transport;
> -			sctp_cmd_hb_timer_update(commands, asoc, t);
> +			sctp_cmd_hb_timer_update(commands, t);
>  			break;

you mean it was not compiling before?

- Arnaldo
