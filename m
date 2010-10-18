From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 1/3] net: fail alloc_netdev_mq if queue count < 1
Date: Mon, 18 Oct 2010 14:46:13 -0700
Message-ID: <AANLkTi=vNa0u_u0uKVxspjbhXho8Zcf=Lzezjw6AUvPJ@mail.gmail.com>
References: <alpine.DEB.1.00.1010181055300.16090@pokey.mtv.corp.google.com>
	<1287437621.2252.766.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, eric.dumazet@gmail.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:4120 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab0JRVqP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 17:46:15 -0400
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o9ILkE5p011644
	for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 14:46:14 -0700
Received: from pxi16 (pxi16.prod.google.com [10.243.27.16])
	by wpaz24.hot.corp.google.com with ESMTP id o9ILk30e013051
	for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 14:46:13 -0700
Received: by pxi16 with SMTP id 16so371273pxi.5
        for <netdev@vger.kernel.org>; Mon, 18 Oct 2010 14:46:13 -0700 (PDT)
In-Reply-To: <1287437621.2252.766.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Off by one?
>

Yes, thanks for catching that.

> Ben.
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 return NULL;
>> + =A0 =A0 }
>> +
>> =A0 =A0 =A0 alloc_size =3D sizeof(struct net_device);
>> =A0 =A0 =A0 if (sizeof_priv) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* ensure 32-byte alignment of private a=
rea */
>
> --
> Ben Hutchings, Senior Software Engineer, Solarflare Communications
> Not speaking for my employer; that's the marketing department's job.
> They asked us to note that Solarflare product names are trademarked.
>
>
