From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v3 1/2] RDS: TCP: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Wed, 16 Mar 2016 07:10:55 -0400
Message-ID: <20160316111055.GB21307@oracle.com>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
 <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
 <56E93596.90503@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	santosh.shilimkar@oracle.com, eric.dumazet@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:19780 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965777AbcCPLLG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 07:11:06 -0400
Content-Disposition: inline
In-Reply-To: <56E93596.90503@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/16/16 11:29), Hannes Frederic Sowa wrote:
> Normally we kmemdup a table per netns and update its data pointer,
> so we can reuse the proc_doint_minmax functions.

I remembered one more thing.. in this particular case, I need to
have my one ->proc_handler, because I need to rds_tcp_sysctl_reset()
existing connections to make them use the new tunable.

--Sowmini
