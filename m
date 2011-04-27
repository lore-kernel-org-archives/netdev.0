From: Steve Hodgson <shodgson@solarflare.com>
Subject: Re: [RFC PATCH] netlink: Increase netlink dump skb message size
Date: Wed, 27 Apr 2011 16:46:40 +0100
Message-ID: <4DB83A60.5040102@solarflare.com>
References: <20110425220157.2012.96707.stgit@gitlad.jf.intel.com>	 <1303799597.2747.214.camel@edumazet-laptop>	 <20110425.235600.104065244.davem@davemloft.net>	 <43F901BD926A4E43B106BF17856F0755018DC497D4@orsmsx508.amr.corp.intel.com> <1303834864.3358.58.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rose, Gregory V" <gregory.v.rose@intel.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:59138 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759326Ab1D0Pqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 11:46:43 -0400
In-Reply-To: <1303834864.3358.58.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/27/2011 04:24 PM, Eric Dumazet wrote:
> Le mardi 26 avril 2011 =C3=A0 09:12 -0700, Rose, Gregory V a =C3=A9cr=
it :
>
>> I'm fine with however you folks want to approach this, just give me =
some direction.
>
> I would just try following patch :
>

This allows the sfc driver to use 102 VFs, up from the current limit of=
=20
45 VFs.

It's unfortunate that this patch isn't sufficient to allow all 127 VFs=20
to be used, but whilst we wait for a new netlink api this is an=20
improvement worth having.

I'd like to see this patch committed.

Thanks Eric,

- Steve
