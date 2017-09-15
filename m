From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net] sctp: do not mark sk dumped when inet_sctp_diag_fill
 returns err
Date: Fri, 15 Sep 2017 08:59:52 -0400
Message-ID: <20170915125952.GB6031@hmswarspite.think-freely.org>
References: <c5398945d4e80ed8b8497675dd0449763fec4eec.1505444568.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
        davem@davemloft.net,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52631 "EHLO
        smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbdIOM75 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 08:59:57 -0400
Content-Disposition: inline
In-Reply-To: <c5398945d4e80ed8b8497675dd0449763fec4eec.1505444568.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 15, 2017 at 11:02:48AM +0800, Xin Long wrote:
> sctp_diag would not actually dump out sk/asoc if inet_sctp_diag_fill
> returns err, in which case it shouldn't mark sk dumped by setting
> cb->args[3] as 1 in sctp_sock_dump().
> 
> Otherwise, it could cause some asocs to have no parent's sk dumped
> in 'ss --sctp'.
> 
> So this patch is to not set cb->args[3] when inet_sctp_diag_fill()
> returns err in sctp_sock_dump().
> 
> Fixes: 8f840e47f190 ("sctp: add the sctp_diag.c file")
> Signed-off-by: Xin Long <lucien.xin@gmail.com>
> ---
>  net/sctp/sctp_diag.c | 1 -
>  1 file changed, 1 deletion(-)
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
