From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 9/9] fix sparse warnings
Date: Mon, 14 Jan 2008 18:34:03 +0100
Message-ID: <478B9D0B.5040301@cosmosbay.com>
References: <20080112064513.803976049@linux-foundation.org>	<20080112064646.659443238@linux-foundation.org>	<4788A17D.5070903@cosmosbay.com>	<20080112130824.54cc1fc3@deepthought> <18315.16984.456053.250600@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>, netdev@vger.kernel.org
To: Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp20.orange.fr ([80.12.242.26]:16584 "EHLO smtp20.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750966AbYANS4O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 13:56:14 -0500
Received: from smtp20.orange.fr (mwinf2016 [172.22.130.116])
	by mwinf2005.orange.fr (SMTP Server) with ESMTP id 4A4761C282A9
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 18:34:58 +0100 (CET)
Received: from me-wanadoo.net (localhost [127.0.0.1])
	by mwinf2016.orange.fr (SMTP Server) with ESMTP id 5ED881C000BF
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 18:34:16 +0100 (CET)
In-Reply-To: <18315.16984.456053.250600@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Robert Olsson a =E9crit :
> Thanks for hacking and improving and the trie... another idea that co=
uld
> be also tested. If we look into routing table we see that most leafs=20
> only has one prefix
>
> Main:
>         Aver depth:     2.57
>         Max depth:      7
>         Leaves:         231173
>
> ip route | wc -l=20
> 241649
>
> Thats 231173/241649 =3D 96% with the current Internet routing.
>
> How about if would have a fastpath and store one entry direct in the=20
> leaf struct this to avoid loading the leaf_info list in most cases?
>
> One could believe that both lookup and dump could improve.
>
>  =20
You mean to include one "leaf_info" inside leaf structure, so that we=20
can access it without cache line miss ?





