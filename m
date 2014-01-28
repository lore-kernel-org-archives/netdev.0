From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: gre: use icmp_hdr() to get inner ip header
Date: Mon, 27 Jan 2014 20:39:00 -0800 (PST)
Message-ID: <20140127.203900.1924366993738449780.davem@davemloft.net>
References: <52E728D7.70506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, netdev@vger.kernel.org, pshelar@nicira.com
To: duanj.fnst@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39517 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534AbaA1EjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jan 2014 23:39:01 -0500
In-Reply-To: <52E728D7.70506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Date: Tue, 28 Jan 2014 11:49:43 +0800

> 
> When dealing with icmp messages, the skb->data points the
> ip header that triggered the sending of the icmp message.
> 
> In gre_cisco_err(), the parse_gre_header() is called, and the
> iptunnel_pull_header() is called to pull the skb at the end of
> the parse_gre_header(), so the skb->data doesn't point the
> inner ip header.
> 
> Unfortunately, the ipgre_err still needs those ip addresses in
> inner ip header to look up tunnel by ip_tunnel_lookup().
> 
> So just use icmp_hdr() to get inner ip header instead of skb->data.
> 
> Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>

Applied and queued up for -stable, thanks.
