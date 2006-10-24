From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: Fix xfrm_state accounting
Date: Tue, 24 Oct 2006 15:34:22 -0700 (PDT)
Message-ID: <20061024.153422.66059770.davem@davemloft.net>
References: <453E8D1A.2040904@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:3794
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422754AbWJXWeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 18:34:17 -0400
To: kaber@trash.net
In-Reply-To: <453E8D1A.2040904@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 25 Oct 2006 00:00:58 +0200

> [XFRM]: Fix xfrm_state accounting
> 
> xfrm_state_num needs to be increased for XFRM_STATE_ACQ states created
> by xfrm_state_find() to prevent the counter from going negative when
> the state is destroyed.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>

Good catch, we've had a few of these lately :-)

Applied, thanks Patrick.
