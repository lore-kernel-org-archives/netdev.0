From: Vincent Bernat <vincent@bernat.im>
Subject: Re: Regression in 4.1 with veth and IFLA_LINK
Date: Wed, 19 Aug 2015 08:44:07 +0200
Message-ID: <1439966648-26195-1-git-send-email-vincent@bernat.im>
References: <87fv3ier4s.fsf@zoro.exoscale.ch>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:34406 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752437AbbHSGxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 02:53:07 -0400
In-Reply-To: <87fv3ier4s.fsf@zoro.exoscale.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Here is a proposed patch to fix this by providing a symlink to the
peer instead. This may not totally replace the use of iflink since the
peer won't be available through netlink anymore but maybe this is good
enough for the intended use.
