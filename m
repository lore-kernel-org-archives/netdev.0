From: Venkat Yekkirala <vyekkirala@TrustedCS.com>
Subject: RE: [PATCH 1/1] secid reconcialiation: Replace unlabeled_t with t
	he network_t
Date: Wed, 4 Oct 2006 10:50:00 -0400
Message-ID: <36282A1733C57546BE392885C0618592015CF85B@chaos.tcs.tcs-sec.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: Venkat Yekkirala <vyekkirala@TrustedCS.com>,
	netdev@vger.kernel.org, selinux@tycho.nsa.gov, jmorris@namei.org,
	sds@tycho.nsa.gov, eparis@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tcsfw4.tcs-sec.com ([65.127.223.133]:44942 "EHLO
	tcsfw4.tcs-sec.com") by vger.kernel.org with ESMTP id S1161147AbWJDOuf
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 10:50:35 -0400
To: Paul Moore <paul.moore@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > Considering the above change, I wonder if it would also 
> make sense to
> > update the secmark to SECINITSID_UNLABELED in the abscence of any
> > external labeling (labeled IPsec or NetLabel)?
> > 
> 
> Ungh, my apologies ... I meant to say "SECINITSID_NETMSG" *not*
> "SECINITSID_UNLABELED".

In the xfrm/NetLabel/semark case, you have configured (domain) labels that
are meant to be carried by the skb. Whereas that's not the case with
network_t.
So, just a flow_in check was in order here.
