From: Flavio Leitner <fbl@redhat.com>
Subject: Re: [PATCH net-next v3 1/2] ipv6: add sysctl_mld_qrv to configure
 query robustness variable
Date: Tue, 2 Sep 2014 15:50:37 -0300
Message-ID: <20140902185037.GH7909@t520.home>
References: <3f38fb1c0c5544de4cea8bb13e0adcbba17bebd3.1409665378.git.hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1863 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754991AbaIBSul (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Sep 2014 14:50:41 -0400
Content-Disposition: inline
In-Reply-To: <3f38fb1c0c5544de4cea8bb13e0adcbba17bebd3.1409665378.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 02, 2014 at 03:49:25PM +0200, Hannes Frederic Sowa wrote:
> This patch adds a new sysctl_mld_qrv knob to configure the mldv1/v2 query
> robustness variable. It specifies how many retransmit of unsolicited mld
> retransmit should happen. Admins might want to tune this on lossy links.
> 
> Also reset mld state on interface down/up, so we pick up new sysctl
> settings during interface up event.
> 
> IPv6 certification requests this knob to be available.
> 
> I didn't make this knob netns specific, as it is mostly a setting in a
> physical environment and should be per host.
> 
> Cc: Flavio Leitner <fbl@redhat.com>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
> ---

Thanks very much Hannes!

Acked-by: Flavio Leitner <fbl@redhat.com>
