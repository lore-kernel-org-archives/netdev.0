From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tcp: don't require root to read tcp_metrics
Date: Thu, 31 Jul 2014 14:07:50 -0700 (PDT)
Message-ID: <20140731.140750.2142330641462047009.davem@davemloft.net>
References: <53D92D92.4090403@cogentembedded.com>
	<1406742617-10556-1-git-send-email-dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sergei.shtylyov@cogentembedded.com, netdev@vger.kernel.org,
	ja@ssi.bg, linux-kernel@vger.kernel.org
To: dbanerje@akamai.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406742617-10556-1-git-send-email-dbanerje@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Debabrata Banerjee <dbanerje@akamai.com>
Date: Wed, 30 Jul 2014 13:50:17 -0400

> commit d23ff7016 (tcp: add generic netlink support for tcp_metrics) introduced
> netlink support for the new tcp_metrics, however it restricted getting of
> tcp_metrics to root user only. This is a change from how these values could
> have been fetched when in the old route cache. Unless there's a legitimate
> reason to restrict the reading of these values it would be better if normal
> users could fetch them.
> 
> Cc: Julian Anastasov <ja@ssi.bg>
> Cc: linux-kernel@vger.kernel.org
> 
> Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>

Applied to net-next, thanks.
