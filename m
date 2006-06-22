From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH 1/3] Rough VJ Channel Implementation - vj_core.patch
Date: Wed, 21 Jun 2006 23:58:56 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0606212354420.15426@d.namei>
References: <20060504.161148.44973535.davem@davemloft.net>
 <200605161102.29472.kelly@au.ibm.com> <20060515.221637.90861876.davem@davemloft.net>
 <200606221205.35161.kelly@au.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:53942 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1751292AbWFVD66 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Jun 2006 23:58:58 -0400
To: Kelly Daly <kelly@au1.ibm.com>
In-Reply-To: <200606221205.35161.kelly@au.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Jun 2006, Kelly Daly wrote:

> +	switch (bp->netchan_buf_proto) {
> +	case __constant_htons(ETH_P_IP): {

__constant_htons and friends should not be used in runtime code, only for 
data being initialized at compile time.



- James
-- 
James Morris
<jmorris@namei.org>
