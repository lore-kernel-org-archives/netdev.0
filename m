From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Subject: Re: [PATCH] ip_tunnel: disable preemption when updating per-cpu tstats
Date: Thu, 12 Nov 2015 17:36:24 +0100
Message-ID: <CAHmME9qF2Xi91BTWNSXBoDmzxyPyqSPbFg8ZDN4S-0kSq-RtKA@mail.gmail.com>
References: <1447342212-5543-1-git-send-email-Jason@zx2c4.com>
	<1447345509.2333208.438003833.012C1A95@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, tgraf@suug.ch,
	Tom Herbert <tom@herbertland.com>,
	Jiri Benc <jbenc@redhat.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from frisell.zx2c4.com ([192.95.5.64]:36732 "EHLO frisell.zx2c4.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932269AbbKLQgc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Nov 2015 11:36:32 -0500
In-Reply-To: <1447345509.2333208.438003833.012C1A95@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2015 at 5:25 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> The canonical way is get_cpu_ptr(stats) / put_cpu_ptr.

Thanks for the pointer. Fixed in v2.
