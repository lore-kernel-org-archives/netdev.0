From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH net-next 04/24] rxrpc: Avoid using stack memory in SG
 lists in rxkad
Date: Wed, 6 Jul 2016 06:19:05 -0700
Message-ID: <CALCETrXYJTvYgyaeOwY6N3T2rH+4J23FSp6FWA7HFXih4=3acQ@mail.gmail.com>
References: <146772433082.21657.14046392058484946464.stgit@warthog.procyon.org.uk>
 <146772435939.21657.15502992311223735001.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andy Lutomirski <luto@kernel.org>,
	linux-afs@lists.infradead.org
To: David Howells <dhowells@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:35628 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386AbcGFNTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 09:19:25 -0400
Received: by mail-vk0-f51.google.com with SMTP id v6so33574897vkb.2
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 06:19:25 -0700 (PDT)
In-Reply-To: <146772435939.21657.15502992311223735001.stgit@warthog.procyon.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 5, 2016 at 6:12 AM, David Howells <dhowells@redhat.com> wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
>
> rxkad uses stack memory in SG lists which would not work if stacks were
> allocated from vmalloc memory.  In fact, in most cases this isn't even
> necessary as the stack memory ends up getting copied over to kmalloc
> memory.

This version no longer applies to Linus' tree, so I'm dropping it from
my series.
