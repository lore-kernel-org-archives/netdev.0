From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH]: Add security check before flushing SAD/SPD
Date: Mon, 26 Mar 2007 23:08:24 -0400 (EDT)
Message-ID: <Line.LNX.4.64.0703262306090.18219@d.namei>
References: <200703262321.l2QNLZlR014240@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, davem@davemloft.net, eparis@redhat.com
To: Joy Latten <latten@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:48462 "EHLO
	mail1.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbXC0DI2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2007 23:08:28 -0400
In-Reply-To: <200703262321.l2QNLZlR014240@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 26 Mar 2007, Joy Latten wrote:

> 
> Sending again since one of the email addresses was incorrect.
> 
> ----------------
> 
> Ok, I have made improvements based on James' and Eric's comments.
> 

Acked-by: James Morris <jmorris@namei.org>


> +			if (xfrm_id_proto_match(x->id.proto, proto) &&
> +			   (err = security_xfrm_state_delete(x)) != 0) {


Still not a showstopper, but standard idiom would be nice at some point.



- James
-- 
James Morris
<jmorris@namei.org>
