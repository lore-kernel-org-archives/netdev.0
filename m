From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6 addrconf: source address selection, Rule 7: Prefer temporary addresses (RFC 6724)
Date: Tue, 26 Nov 2013 09:54:04 +0100
Message-ID: <20131126085404.GA20630@order.stressinduktion.org>
References: <1385396205-6105-1-git-send-email-fx.lebail@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, dcbw@redhat.com,
	jiri@resnulli.us
To: fx.lebail@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:38773 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719Ab3KZIy1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 03:54:27 -0500
Content-Disposition: inline
In-Reply-To: <1385396205-6105-1-git-send-email-fx.lebail@yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Added Jiri and Dan]

On Mon, Nov 25, 2013 at 05:16:45PM +0100, fx.lebail@yahoo.com wrote:
> The RFC 6724 change the default recommendation for source address selection
> Rule 7 to prefer temporary addresses rather than public addresses,
> while providing an administrative override.
> 
> The administrative override is based on the prefer_src_public sysctl.

I like the idea and it could be useful in addition to the new
IFA_F_MANAGETEMPADDR flag which should show up any time soon.

With IFA_F_MANAGETEMPADDR iproute/netlink could add a public address
and indicate the kernel it should also generate a new temporary address
without touching the use_tempaddr knob. So there is no possiblity to
change the priority of public and temporary addresses any more. This
patch could restore that.

A netconf API for this would be nice, too.

Jiri, Dan do you agree?

Greetings,

  Hannes
