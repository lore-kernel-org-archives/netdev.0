From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH ver2] Avoid enqueuing skb for default qdiscs
Date: Thu, 6 Aug 2009 13:49:46 -0700
Message-ID: <20090806134946.1772dd5a@nehalam>
References: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Jarek Poplawski <jarkao2@gmail.com>,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Krishna Kumar <krkumar2@in.ibm.com>, kaber@trash.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51648 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755865AbZHFUtx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 16:49:53 -0400
In-Reply-To: <20090806114421.19208.39374.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Aug 2009 17:14:21 +0530
Krishna Kumar <krkumar2@in.ibm.com> wrote:

> +static inline int qdisc_qlen(struct Qdisc *q)
> +{
> +	return q->q.qlen;
> +}
> +

Why?
This kind of oneline accessor decreases the code clarity.


-- 
