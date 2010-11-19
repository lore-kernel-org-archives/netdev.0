From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC][PATCH 0/5] RFS hardware acceleration (v2)
Date: Fri, 19 Nov 2010 11:42:02 -0800
Message-ID: <AANLkTikk-nwCxjWwx-ttw3MHnGxDvOdFZi1s6czD4BQO@mail.gmail.com>
References: <1290192176.2671.38.camel@bwh-desktop>
	<1290194386.2671.59.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:63369 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751544Ab0KSTmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 14:42:08 -0500
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id oAJJg5D8005352
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 11:42:06 -0800
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by wpaz24.hot.corp.google.com with ESMTP id oAJJg4si018186
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 11:42:04 -0800
Received: by pwi5 with SMTP id 5so1095784pwi.39
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 11:42:04 -0800 (PST)
In-Reply-To: <1290194386.2671.59.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> So accelerated RFS gave a 6-13% improvement over software RFS in
> transaction rate for these various cases.
>

Very nice preliminary results!  Are you seeing any OOO packets in
these tests, I am still holding on to hope that these can be avoided
with such mechanisms.

Tom
