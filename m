From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: simpler bic default
Date: Tue, 19 Sep 2006 15:44:35 -0700 (PDT)
Message-ID: <20060919.154435.102044066.davem@davemloft.net>
References: <20060919.142007.06541289.davem@davemloft.net>
	<20060919143209.1164d803@localhost.localdomain>
	<20060919214304.GB13543@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:18112
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751362AbWISWob (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Sep 2006 18:44:31 -0400
To: bert.hubert@netherlabs.nl
In-Reply-To: <20060919214304.GB13543@outpost.ds9a.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: bert hubert <bert.hubert@netherlabs.nl>
Date: Tue, 19 Sep 2006 23:43:05 +0200

> On Tue, Sep 19, 2006 at 02:32:09PM -0700, Stephen Hemminger wrote:
> > Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> 
> # CONFIG_TCP_CONG_ADVANCED is not set
> # CONFIG_DEFAULT_BIC is not set
> # CONFIG_DEFAULT_CUBIC is not set
> # CONFIG_DEFAULT_HTCP is not set
> # CONFIG_DEFAULT_VEGAS is not set
> # CONFIG_DEFAULT_WESTWOOD is not set
> # CONFIG_DEFAULT_RENO is not set
> CONFIG_DEFAULT_TCP_CONG="bic"
> 
> There is no "bic" in the kernel now - will this do the right thing?

This is wrong.

When TCP_CONG_ADVANCED is disabled, TCP_CONG_BIC should always be set
and be the default, but that's not what the new code is doing.

I'm reverting Stephen's patch (again) until this is all sorted
out as things are still broken in various ways even with the
followon patch.
