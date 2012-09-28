From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC PATCH net-next] tcp: introduce tcp_tw_interval to specifiy
 the time of TIME-WAIT
Date: Fri, 28 Sep 2012 14:39:59 +0800
Message-ID: <1348814399.7264.44.camel@cr0>
References: <1348735261-29225-1-git-send-email-amwang@redhat.com>
	 <20120927.130529.620560818048014548.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, kaber@trash.net,
	edumazet@google.com, nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:3703 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751610Ab2I1Gkm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Sep 2012 02:40:42 -0400
In-Reply-To: <20120927.130529.620560818048014548.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-27 at 13:05 -0400, David Miller wrote:
> 
> Without appropriate confirmation that an early time-wait reuse is
> valid, decreasing this interval can only be dangerous.

Yeah, would a proper documentation cure this? Something like we did for
other tuning:

"It should not be changed without advice/request of technical experts."
