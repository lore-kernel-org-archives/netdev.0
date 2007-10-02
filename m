From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] qla3xxx: bugfix: Add memory barrier before accessing
 rx completion.
Date: Tue, 02 Oct 2007 12:55:21 -0400
Message-ID: <470277F9.3030204@garzik.org>
References: <20071001184141.GA22534@linux-7mw0.qlogic.org> <1191264203681-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ron Mercer <ron.mercer@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:35801 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752055AbXJBQzX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 12:55:23 -0400
In-Reply-To: <1191264203681-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ron Mercer wrote:
> Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> ---
>  drivers/net/qla3xxx.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
> index 69da95b..c3fe1c7 100755
> --- a/drivers/net/qla3xxx.c
> +++ b/drivers/net/qla3xxx.c
> @@ -2248,6 +2248,7 @@ static int ql_tx_rx_clean(struct ql3_adapter *qdev,
>  		qdev->rsp_consumer_index) && (work_done < work_to_do)) {
>  
>  		net_rsp = qdev->rsp_current;
> +		rmb();
>  		switch (net_rsp->opcode) {

applied 1-2


