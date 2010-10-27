From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH] ipv6: addrconf: clear IPv6 addresses and routes when
 losing link
Date: Wed, 27 Oct 2010 09:03:38 -0700
Message-ID: <AANLkTinA+znFn4txgq_2=njuX+eCTNJW+n_psbMYkU9d@mail.gmail.com>
References: <AANLkTikC4pv8aOODM2pOg2bKQGL69wivcUU3f9ZziPhe@mail.gmail.com>
 <4CC78F19.9080504@hp.com> <AANLkTikTT5ie-R61rA9NucgGi5RBOPpXZLMYQRa_wb7j@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: =?ISO-8859-2?Q?Maciej_=AFenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:56670 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756235Ab0J0QEC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 12:04:02 -0400
Received: from kpbe16.cbf.corp.google.com (kpbe16.cbf.corp.google.com [172.25.105.80])
	by smtp-out.google.com with ESMTP id o9RG40Ge024241
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 09:04:00 -0700
Received: from gyb13 (gyb13.prod.google.com [10.243.49.77])
	by kpbe16.cbf.corp.google.com with ESMTP id o9RG3kgp007738
	for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 09:03:58 -0700
Received: by gyb13 with SMTP id 13so654377gyb.37
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 09:03:58 -0700 (PDT)
In-Reply-To: <AANLkTikTT5ie-R61rA9NucgGi5RBOPpXZLMYQRa_wb7j@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 27, 2010 at 1:35 AM, Maciej =C5=BBenczykowski
<zenczykowski@gmail.com> wrote:
> So how does all this work with privacy addresses, established
> connections, and a link flap?

The current privacy address comes back because it's a time-based hash.
I think the old ones are gone. Still, I think it's better that
connections from 1 day ago don't work any more (the default for
privacy addresses is 1 day), than if all new and all old connections
don't work any more.
