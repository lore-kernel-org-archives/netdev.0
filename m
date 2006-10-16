From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] NET : Suspicious locking in reqsk_queue_hash_req()
Date: Mon, 16 Oct 2006 18:56:02 +0200
Message-ID: <200610161856.03334.dada1@cosmosbay.com>
References: <20061010.191547.83619974.davem@davemloft.net> <200610161107.19771.dada1@cosmosbay.com> <39e6f6c70610160916x36c86453pa128950896cfc17d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:24228 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1422686AbWJPQ4H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 12:56:07 -0400
To: "Arnaldo Carvalho de Melo" <arnaldo.melo@gmail.com>
In-Reply-To: <39e6f6c70610160916x36c86453pa128950896cfc17d@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 16 October 2006 18:16, Arnaldo Carvalho de Melo wrote:
> On 10/16/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
> > (Sorry, patch inlined this time)
> >
> > Hi David
> >
> > While browsing include/net/request_sock.h I found this suspicious locking
> > protecting the SYN table hash table. I think this patch is necessary.
> >
> > Thank you
>
> Interesting, just checked and it was there before I moved this out of tcp
> land:

Well, the bug was there before you put your hands on the code (I checked 
linux-2.4.33 & linux-2.4.1 , bug present on both versions)

:)

Eric
