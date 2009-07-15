From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird problem
Date: Thu, 16 Jul 2009 00:43:16 +0200
Message-ID: <20090715224316.GA15099@ami.dom.local>
References: <20090708223459.GB3666@ami.dom.local> <4A5679CC.800@itcare.pl> <4A568444.7010307@itcare.pl> <20090710144754.GA25385@ami.dom.local> <20090711062455.GA3095@ami.dom.local> <4A5BC2B6.9020709@itcare.pl> <20090714162425.GA3090@ami.dom.local> <4A5E38EE.2090405@itcare.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Network Development list <netdev@vger.kernel.org>
To: =?iso-8859-2?Q?Pawe=B3?= Staszewski <pstaszewski@itcare.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f228.google.com ([209.85.218.228]:35953 "EHLO
	mail-bw0-f228.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756282AbZGOWnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 18:43:49 -0400
Received: by bwz28 with SMTP id 28so1715503bwz.37
        for <netdev@vger.kernel.org>; Wed, 15 Jul 2009 15:43:48 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <4A5E38EE.2090405@itcare.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 15, 2009 at 10:15:42PM +0200, Pawe=B3 Staszewski wrote:
=2E..
> So is there some patch or there will be patch that turn off definitel=
y =20
> route cache ?
>

You did it already with rt_cache_rebuild_count =3D -1 or 0 (without my
patches). You can additionally try to set a very minimal hash table
size with kernel boot param "rhash_entries" to limit timers work etc.

Regards,
Jarek P.
