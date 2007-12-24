From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 action ipt + iptables 1.4.0
Date: Mon, 24 Dec 2007 08:50:51 -0500
Message-ID: <1198504251.9642.11.camel@localhost>
References: <20071224090622.M86562@visp.net.lb>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:27392 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751391AbXLXNu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2007 08:50:56 -0500
Received: by wa-out-1112.google.com with SMTP id v27so2699197wah.23
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2007 05:50:56 -0800 (PST)
In-Reply-To: <20071224090622.M86562@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2007-24-12 at 11:31 +0200, Denys Fedoryshchenko wrote:
> Seems latest iproute2(even from GIT) searching for libipt_MARK (for example),
> while it is libxt_MARK.

It seems that iptables broke backward compatibility.

> Even if i correct names it will be still not functional
> "undefined symbol: xtables_register_target"
> 
> Probably some other issues actual with new version of iptables libraries?

Yes. We do depend on libipt and expect the libraries to be in some 
environment variable IPTABLES_LIB_DIR/libipt_%s 
by default (if environment variable IPTABLES_LIB_DIR is not defined) we
look in /usr/local/lib/iptables

in iproute2 we also need to copy over headers into include/libiptc

Pablo - can we not have a backward compat mode to avoid these hassles?

cheers,
jamal

