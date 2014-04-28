From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Mon, 28 Apr 2014 20:12:03 +0200
Message-ID: <535E99F3.3050404@enst-bretagne.fr>
References: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:51559 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932982AbaD1T3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 15:29:21 -0400
In-Reply-To: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 27/04/2014 01:00, Tom Herbert a =E9crit :
>  	net->ipv6.sysctl.flowlabel_consistency =3D 1;
> +	net->ipv6.sysctl.auto_flowlabels =3D 1;

I do not like setting this option to one by default. The idea of
flowlabel_consistency above was to be sure that all labels given by the
host are in the control of the flow label manager.

By enabling auto_flowlabels, we can have conflict between the flow labe=
l
manager policy, and a randomly generated label.

And I do not have a strong opinion on it, but perhaps should
auto_flowlabels depends of a disabled flowlabel_consistency, to have a
coherent behaviour for users.

Regards,

=46lorent.
