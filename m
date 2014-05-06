From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/1] inet: fix sysctl_local_ports init when
 namespaces are used
Date: Wed, 7 May 2014 00:51:45 +0200
Message-ID: <20140506225145.GA28325@electric-eye.fr.zoreil.com>
References: <20140506055341.GA9051@electric-eye.fr.zoreil.com>
 <CAHA+R7MpYxEaAW+ykUg2F5Cpy36cenm7oNv7eqA-C=HsbBrhTg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Stefan de Konink <stefan@konink.de>,
	Daniel Borkmann <dborkman@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:52049 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaEFWv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2014 18:51:58 -0400
Content-Disposition: inline
In-Reply-To: <CAHA+R7MpYxEaAW+ykUg2F5Cpy36cenm7oNv7eqA-C=HsbBrhTg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <cwang@twopensource.com> :
> On Mon, May 5, 2014 at 10:53 PM, Francois Romieu <romieu@fr.zoreil.com> wrote:
> > Bug: https://bugzilla.kernel.org/show_bug.cgi?id=75221
> >
> 
> Well, $subject sucks, it only fixes !CONFIG_PROC_SYSCTL case actually...

Sure. It says "fix something" though.

> > Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
> > Reported-by: Stefan de Konink <stefan@konink.de>
> > Tested-by: Stefan de Konink <stefan@konink.de>
> 
> I had some better fixes pending (I already tested them, just waiting to
> submit).

Before ping patch (!CONFIG_PROC_SYSCTL): the ping group range is zero due
to kzalloc and friends.

After ping patch  (!CONFIG_PROC_SYSCTL): the ping group range is disabled
and it can't be set afterwards.

It isn't exactly "still work" but it's a welcome improvement.

Feel free to submit formally so that davem can pick those up.

-- 
Ueimor
