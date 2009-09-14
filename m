From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: [PATCH RFC] tun: export underlying socket
Date: Mon, 14 Sep 2009 11:07:25 +0300
Message-ID: <15ddcffd0909140107m4d94f5abh5405074b654bd15d@mail.gmail.com>
References: <20090910125929.GA32593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>, m.s.tsirkin@gmail.com,
	netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	Or Gerlitz <ogerlitz@voltaire.com>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:50836 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996AbZINIHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 04:07:22 -0400
Received: by fxm17 with SMTP id 17so655596fxm.37
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2009 01:07:25 -0700 (PDT)
In-Reply-To: <20090910125929.GA32593@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/10/09, Michael S. Tsirkin <mst@redhat.com> wrote:
>  This way, code using raw sockets to inject packets into a physical device,
>  can support injecting packets into host network stack almost without modification.
>  First user of this interface will be vhost virtualization accelerator.

vhost injects packet into physical device, what is the use case of
vhost injecting packet into the host network stack?

Or.
