From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [tipc-discussion] [PATCH net-next] tipc: remove two indentation levels in tipc_recv_msg routine
Date: Tue, 29 Oct 2013 12:42:58 -0000
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B73BD@saturn3.aculab.com>
References: <1383044471-12982-1-git-send-email-ying.xue@windriver.com>	<AE90C24D6B3A694183C094C60CF0A2F6026B73BC@saturn3.aculab.com> <20131029120708.GI14038@eerihug-hybrid.rnd.ki.sw.ericsson.se> <526FACA9.9020004@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: <jon.maloy@ericsson.com>, <netdev@vger.kernel.org>,
	<Paul.Gortmaker@windriver.com>,
	<tipc-discussion@lists.sourceforge.net>, <davem@davemloft.net>
To: =?Windows-1252?Q?Andreas_Bofj=E4ll?= <andreas.bofjall@ericsson.com>,
	"Erik Hugne" <erik.hugne@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:59144 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1752508Ab3J2Mpf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 08:45:35 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 26830-07 for <netdev@vger.kernel.org>;
 Tue, 29 Oct 2013 12:45:32 +0000 (GMT)
Content-class: urn:content-classes:message
In-Reply-To: <526FACA9.9020004@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>   		continue;
> +
> +unlock:
> +		tipc_node_unlock(n_ptr);
>   cont:
>   		kfree_skb(buf);
>   	}

Might be better to call the labels 'unlock_discard' and 'discard'.

	David
