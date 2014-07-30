From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH] tcp: don't require root to read tcp_metrics
Date: Wed, 30 Jul 2014 22:33:34 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1407302228460.1826@ja.home.ssi.bg>
References: <1406740415-9386-1-git-send-email-dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Debabrata Banerjee <dbanerje@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406740415-9386-1-git-send-email-dbanerje@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Wed, 30 Jul 2014, Debabrata Banerjee wrote:

> commit d23ff701643a4a725e2c7a8ba2d567d39daa29ea introduced netlink support for
> the new tcp_metrics, however it restricted getting of tcp_metrics to root user
> only. This is a change from how these values could have been fetched when in
> the old route cache. Unless there's a legitimate reason to restrict the reading
> of these values it would be better if normal users could fetch them.

	Not sure how fatal is to show TCP fastopen cookies to
any user. Otherwise, I don't remember for other restrictions.

Regards

--
Julian Anastasov <ja@ssi.bg>
