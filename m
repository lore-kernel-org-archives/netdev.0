From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 11:09:23 +0300
Message-ID: <20090914080923.GC14030@redhat.com>
References: <20090910125929.GA32593@redhat.com> <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, Or Gerlitz <ogerlitz@voltaire.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1321 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752429AbZINILM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Sep 2009 04:11:12 -0400
Content-Disposition: inline
In-Reply-To: <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 14, 2009 at 11:07:25AM +0300, Or Gerlitz wrote:
> On 9/10/09, Michael S. Tsirkin <mst@redhat.com> wrote:
> >  This way, code using raw sockets to inject packets into a physical device,
> >  can support injecting packets into host network stack almost without modification.
> >  First user of this interface will be vhost virtualization accelerator.
> 
> vhost injects packet into physical device, what is the use case of
> vhost injecting packet into the host network stack?

The case where the user requires bridging, typically.

> Or.
