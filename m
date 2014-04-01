From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [PATCH v3 net] xen-netback: disable rogue vif in kthread context
Date: Tue, 1 Apr 2014 12:36:52 +0100
Message-ID: <533AA4D4.10709@citrix.com>
References: <1396352037-7721-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xen.org>,
	<zoltan.kiss@citrix.com>, <edwin@etorok.net>,
	Ian Campbell <ian.campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:54318 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752982AbaDALgy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Apr 2014 07:36:54 -0400
In-Reply-To: <1396352037-7721-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/14 12:33, Wei Liu wrote:
> @@ -1574,6 +1575,16 @@ int xenvif_kthread(void *data)
>  		wait_event_interruptible(vif->wq,
>  					 rx_work_todo(vif) ||
>  					 kthread_should_stop());

I think you're still missing a || vif->disabled from this wait_event
conditional.

David
