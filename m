From: James Morris <jmorris@namei.org>
Subject: Re: [RFC 2/3] secid reconciliation on inbound: add LSM hooks
Date: Tue, 1 Aug 2006 19:09:50 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608011908430.14724@d.namei>
References: <44CFD0E2.9070709@trustedcs.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	chanson@trustedcs.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.sea5.speakeasy.net ([69.17.117.5]:54448 "EHLO
	mail3.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1750704AbWHAXJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 19:09:53 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <44CFD0E2.9070709@trustedcs.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, Venkat Yekkirala wrote:

> -	if (err)
> -		goto out;
> +	/* if (err) */
> +	/*	goto out; */
> 
> -	err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
> -out:	+	/* err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad); */
> +out:	 	return err;
> }


Did you mean to leave the call to selinux_xfrm_sock_rcv_skb() commented 
out?



- James
-- 
James Morris
<jmorris@namei.org>
