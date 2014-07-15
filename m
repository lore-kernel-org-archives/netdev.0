From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net 1/1] net: ppp: fix creating PPP pass and active filters
Date: Tue, 15 Jul 2014 08:59:24 +0200
Message-ID: <53C4D14C.607@redhat.com>
References: <53C28297.4080507@kristov.de> <53C29DAA.8020405@gmail.com> <20140713180735.209671xd9qjsgmo7@berry.schulz.ip-v6.eu> <53C2D541.8080900@redhat.com> <20140715065458.15013qglk08wv3mq@kristov.noip.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org,
	linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: Christoph Schulz <develop@kristov.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10333 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757844AbaGOG7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 02:59:51 -0400
In-Reply-To: <20140715065458.15013qglk08wv3mq@kristov.noip.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 06:54 AM, Christoph Schulz wrote:
> Hello!
>
> Daniel Borkmann schrieb am Sun, 13 Jul 2014 20:51:45 +0200:
>
>> I think going with the first variant is just fine.
>
> Well, then I need not change anything, do I? This first variant causes checkpatch to warn twice about a line exceeding 80 characters:
>
> WARNING: line over 80 characters
> #83: FILE: drivers/net/ppp/ppp_generic.c:771:
> +                               err = sk_unattached_filter_create(&ppp->pass_filter,
>
> WARNING: line over 80 characters
> #102: FILE: drivers/net/ppp/ppp_generic.c:797:
> +                               err = sk_unattached_filter_create(&ppp->active_filter,
>
> But I don't see how to shorten them. This is because "sk_unattached_filter_create" is such a long identifier...

Well, this is a soft-limit, and in this particular circumstance
it should be fine to use your original proposal. I don't see how
Varka's suggestions make this better in _any way_, rather the
very opposite.
