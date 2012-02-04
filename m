From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Connect hangs for a while before returns -1 with ECONNREFUSED
 on 3.2 for loopback
Date: Sat, 04 Feb 2012 22:26:27 +0100
Message-ID: <1328390787.2731.48.camel@edumazet-laptop>
References: <4F2B7DF1.5050303@oktetlabs.ru>
	    <1328279894.2157.23.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	    <1328282126.2157.27.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	   <1328358402.2731.11.camel@edumazet-laptop>
	   <alpine.LFD.2.00.1202041537370.1496@ja.ssi.bg>
	 <1328374715.2731.21.camel@edumazet-laptop>
	  <alpine.LFD.2.00.1202041912430.1496@ja.ssi.bg>
	 <1328384630.2731.46.camel@edumazet-laptop>
	 <alpine.LFD.2.00.1202042217180.1496@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yurij M. Plotnikov" <Yurij.Plotnikov@oktetlabs.ru>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:46517 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752956Ab2BDV0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Feb 2012 16:26:34 -0500
Received: by wics10 with SMTP id s10so3391526wic.19
        for <netdev@vger.kernel.org>; Sat, 04 Feb 2012 13:26:33 -0800 (PST)
In-Reply-To: <alpine.LFD.2.00.1202042217180.1496@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 04 f=C3=A9vrier 2012 =C3=A0 22:51 +0200, Julian Anastasov a =C3=
=A9crit :
> 	Yes, it is optimized by compiler. I just wanted
> to add a function that has the list of all input parameters
> that are modified by the routing lookup, so that we can
> use it at every place that needs to reuse the fl4. It also
> shows that in ip_route_connect and ip_route_newports
> fl4->daddr and fl4->saddr from previous step are reused
> while the other fields are set with original values.
> For icmp_route_lookup it will help when xfrm_decode_session_reverse
> fills fl4_dec to clarify which fields should be provided
> to __ip_route_output_key because now for me it is not clear
> which fields should be preserved. Currently, only tos is
> provided but if xfrm_decode_session_reverse is changed one
> day to fill oif we have to be specific what happens exactly.
>=20
> > __ip_route_output_key() always had the possibility to change
> > saddr/daddr, I dont think we have to deal with it.
>=20
> 	I rely on the fact that fields that are reused
> do not generate code but it will make the logic visible.
> It will help in case one day we modify the semantics for
> the fl4 fields (input/output type).
>=20

=46air enough, please submit your patch with proper changelog / credits
then ?

Thanks
