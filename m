From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] rhashtable: better high order allocation
 attempts
Date: Fri, 20 Feb 2015 05:46:15 -0800
Message-ID: <1424439975.5565.0.camel@edumazet-glaptop2.roam.corp.google.com>
References: <cover.1424389682.git.daniel@iogearbox.net>
	 <ef7f956fc36000761a652f2bcb395d0eb7300802.1424389682.git.daniel@iogearbox.net>
	 <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Daniel Borkmann' <daniel@iogearbox.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"tgraf@suug.ch" <tgraf@suug.ch>,
	"johunt@akamai.com" <johunt@akamai.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:44718 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbbBTNqR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 08:46:17 -0500
Received: by pdbnh10 with SMTP id nh10so7662037pdb.11
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 05:46:17 -0800 (PST)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CAE676F@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-20 at 10:11 +0000, David Laight wrote:
> From: Daniel Borkmann
> > When trying to allocate future tables via bucket_table_alloc(), it seems
> > overkill on large table shifts that we probe for kzalloc() unconditionally
> > first, as it's likely to fail.
> 
> How about a two-level array for large tables?
> Then you don't need to allocate more than 1 page at a time?

This is called vmalloc() in linux kernel.
