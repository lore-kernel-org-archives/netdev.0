From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: netem and hierarchical ingress traffic shaping
Date: Sun, 18 Dec 2011 11:55:49 -0800
Message-ID: <20111218115549.0d9e1259@nehalam.linuxnetplumber.net>
References: <1324185132.8451.439.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37015 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751776Ab1LRTzx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Dec 2011 14:55:53 -0500
In-Reply-To: <1324185132.8451.439.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 18 Dec 2011 00:12:12 -0500
"John A. Sullivan III" <jsullivan@opensourcedevel.com> wrote:

> Since netem appears to be classless, we realized we would need to
> replace the SFQ on each leaf with netem which we really didn't want to
> do - not only to not lose SFQ but because we didn't want to maintain the
> netem parameters on each leaf.  So, we activated our ifb1 interface,
> placed netem on it and redirected all the egress traffic to ifb1.  Taht
> worked fine.

Current versions of netem can take one class.
