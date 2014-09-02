From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next v3 2/2] ipv4: implement igmp_qrv sysctl to tune
 igmp robustness variable
Date: Tue, 2 Sep 2014 15:51:29 -0300
Message-ID: <20140902185128.GI7909@t520.home>
References: <3f38fb1c0c5544de4cea8bb13e0adcbba17bebd3.1409665378.git.hannes@stressinduktion.org>
 <b24ad902c532616c7683565df3a0fcc9d925da9c.1409665378.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55131 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754751AbaIBSvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 14:51:35 -0400
Content-Disposition: inline
In-Reply-To: <b24ad902c532616c7683565df3a0fcc9d925da9c.1409665378.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2014 at 03:49:26PM +0200, Hannes Frederic Sowa wrote:
> As in IPv6 people might increase the igmp query robustness variable to
> make sure unsolicited state change reports aren't lost on the network. Add
> and document this new knob to igmp code.
> 
> RFCs allow tuning this parameter back to first IGMP RFC, so we also use
> this setting for all counters, including source specific multicast.
> 
> Also take over sysctl value when upping the interface and don't reuse
> the last one seen on the interface.
> 
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Thanks again,
Acked-by: Flavio Leitner <fbl@redhat.com>
