From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Question]: reqsk table size limited to 16?
Date: Fri, 02 Oct 2009 08:50:38 +0200
Message-ID: <4AC5A2BE.5060209@cosmosbay.com>
References: <20091002061134.GC5646@gerrit.erg.abdn.ac.uk> <20091002062532.GA15755@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:57914 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756652AbZJBGug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2009 02:50:36 -0400
In-Reply-To: <20091002062532.GA15755@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker a =E9crit :
> Please forget the posting, this is correct; the clamping is
>=20
>   8 <=3D nr_table_entries <=3D  sysctl_max_syn_backlog,
>=20
> i.e. the minimum table size is 16.
>

Yes, agreed, 8+1 -> 16

