From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Fix typos in proc output string
Date: Mon, 10 Nov 2008 13:38:02 -0800 (PST)
Message-ID: <20081110.133802.83808112.davem@davemloft.net>
References: <877i7hyuf0.fsf@tac.ki.iif.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: wferi@niif.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33304
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751484AbYKJViC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 16:38:02 -0500
In-Reply-To: <877i7hyuf0.fsf@tac.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ferenc Wagner <wferi@niif.hu>
Date: Thu, 06 Nov 2008 12:18:27 +0100

> Signed-off-by: Ferenc Wagner <wferi@niif.hu>
 ...
> @@ -314,7 +314,7 @@ static int vlandev_seq_show(struct seq_file *seq, void *offset)
>  		   dev_info->ingress_priority_map[6],
>  		   dev_info->ingress_priority_map[7]);
>  
> -	seq_printf(seq, "EGRESSS priority Mappings: ");
> +	seq_printf(seq, " EGRESS priority mappings: ");
>  	for (i = 0; i < 16; i++) {
>  		const struct vlan_priority_tci_mapping *mp
>  			= dev_info->egress_priority_map[i];

The typo fix is clearly correct, but adding the leading
space is not.  Are you simply trying to make the values
line up with the INGRESS ones on the previous line?

Anyways, I'm applying this fix, but I wish you had clarified
the change as it wasn't totally clear even to me.

Thanks!
