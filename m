From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] bridge: allow setting hash_max + multicast_router
 if interface is down
Date: Thu, 21 May 2015 18:56:41 -0700
Message-ID: <555E8CD9.9030004@cumulusnetworks.com>
References: <1432256161-4425-1-git-send-email-linus.luessing@c0d3.blue>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	linux-kernel@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>,
	Satish Ashok <sashok@cumulusnetworks.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: =?UTF-8?B?TGludXMgTMO8c3Npbmc=?= <linus.luessing@c0d3.blue>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34614 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754013AbbEVB4n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 May 2015 21:56:43 -0400
Received: by pdbnk13 with SMTP id nk13so6310438pdb.1
        for <netdev@vger.kernel.org>; Thu, 21 May 2015 18:56:43 -0700 (PDT)
In-Reply-To: <1432256161-4425-1-git-send-email-linus.luessing@c0d3.blue>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/21/15, 5:56 PM, Linus L=C3=BCssing wrote:
> Network managers like netifd (used in OpenWRT for instance) try to
> configure interface options after creation but before setting the
> interface up.
>
> Unfortunately the sysfs / bridge currently only allows to configure t=
he
> hash_max and multicast_router options when the bridge interface is up=
=2E
> But since br_multicast_init() doesn't start any timers and only sets
> default values and initializes timers it should be save to reconfigur=
e
> the default values after that, before things actually get active afte=
r
> the bridge is set up.
>
> With this patch hash_max and multicast_router attributes can be
> changed even if the according bridge (port) is down, just like other
> other bridge (port) attributes allow too.
>
> Signed-off-by: Linus L=C3=BCssing <linus.luessing@c0d3.blue>
> ---
> Changelog:
> * [RFC PATCH net-next] -> [PATCH net-next]
Acked-by: Roopa Prabhu <roopa@cumulusnetworks.com>

we have a similar patch in-house waiting to be up-streamed.

thanks.
