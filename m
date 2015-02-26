From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: Re: [PATCH net-next 1/7] net: bluetooth: compact struct bt_skb_cb
 by inlining struct hci_req_ctrl
Date: Thu, 26 Feb 2015 09:02:22 +0200
Message-ID: <20150226090222.5754a610@halley>
References: <1424916612-744-1-git-send-email-eyal.birger@gmail.com>
	<1424916612-744-2-git-send-email-eyal.birger@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, willemb@google.com, edumazet@google.com,
	marcel@holtmann.org, netdev@vger.kernel.org
To: Eyal Birger <eyal.birger@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:37919 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752769AbbBZHCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:02:34 -0500
Received: by wgha1 with SMTP id a1so8164468wgh.5
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 23:02:32 -0800 (PST)
In-Reply-To: <1424916612-744-2-git-send-email-eyal.birger@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2015 04:10:06 +0200 Eyal Birger <eyal.birger@gmail.com> wrote:
> struct hci_req_ctrl is never used outside of struct bt_skb_cb;
> Inlining it frees 8 bytes on a 64 bit system in skb->cb[] allowing
> the addition of more ancillary data.
> 
> Signed-off-by: Eyal Birger <eyal.birger@gmail.com>

Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
