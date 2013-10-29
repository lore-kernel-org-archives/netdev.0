From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next] tipc: remove two indentation levels in tipc_recv_msg routine
Date: Tue, 29 Oct 2013 11:13:09 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73BC@saturn3.aculab.com>
References: <1383044471-12982-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <Paul.Gortmaker@windriver.com>, <jon.maloy@ericsson.com>,
	<erik.hugne@ericsson.com>, <tipc-discussion@lists.sourceforge.net>,
	<netdev@vger.kernel.org>
To: "Ying Xue" <ying.xue@windriver.com>, <davem@davemloft.net>,
	<maloy@donjonn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:57391 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754505Ab3J2LPg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 07:15:36 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 08947-06 for <netdev@vger.kernel.org>;
 Tue, 29 Oct 2013 11:15:30 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <1383044471-12982-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The message dispatching part of tipc_recv_msg() is wrapped layers of
> while/if/if/switch, causing out-of-control indentation and does not
> look very good. We reduce two indentation levels by separating the
> message dispatching from the blocks that checks link state and
> sequence numbers, allowing longer function and arg names to be
> consistently indented without wrapping. This is a cosmetic change
> that does not alter the operation of TIPC in any way.
...
> +			tipc_node_unlock(n_ptr);
> +			goto cont;
> +		}
...
>		continue;
>  cont:
>  		kfree_skb(buf);
>  	}

I can only see one 'goto cont', an explicit kfree_skb() and
continue would be clearer.

	David
