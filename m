From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [RFC 2/3] secid reconciliation on inbound: add LSM hooks
Date: Wed, 2 Aug 2006 08:49:22 -0400
Message-ID: <36282A1733C57546BE392885C061859201466C09@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: netdev@vger.kernel.org, selinux@tycho.nsa.gov, sds@tycho.nsa.gov,
	Chad Hanson <chanson@TrustedCS.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:40965 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1750895AbWHBMtu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 08:49:50 -0400
To: James Morris <jmorris@namei.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > -	if (err)
> > -		goto out;
> > +	/* if (err) */
> > +	/*	goto out; */
> > 
> > -	err = selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad);
> > -out:	+	/* err = 
> selinux_xfrm_sock_rcv_skb(sksec->sid, skb, &ad); */
> > +out:	 	return err;
> > }
> 
> 
> Did you mean to leave the call to selinux_xfrm_sock_rcv_skb() 
> commented 
> out?

I actually meant to take the call out entirely. Will fix this in
the next round.
