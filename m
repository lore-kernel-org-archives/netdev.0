From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC] SECMARK 1.1
Date: Sun, 14 May 2006 20:37:36 +0200
Message-ID: <446778F0.6000705@trash.net>
References: <Pine.LNX.4.64.0605071104590.8588@d.namei> <Pine.LNX.4.64.0605140133560.5506@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: selinux@tycho.nsa.gov, netdev@vger.kernel.org,
	netfilter-devel@lists.netfilter.org,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Daniel J Walsh <dwalsh@redhat.com>,
	Karl MacMillan <kmacmillan@tresys.com>,
	"David S. Miller" <davem@davemloft.net>,
	Thomas Bleher <bleher@informatik.uni-muenchen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39374 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751531AbWENShi
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 May 2006 14:37:38 -0400
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0605140133560.5506@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> @@ -135,6 +175,9 @@ static int __init xt_secmark_init(void)
>  {
>  	int err;
>  
> +	if (tracking_enabled())
> +		need_conntrack();
> +

This will load the conntrack modules even if the track flag is not set.
Wouldn't it be better to put everything related to connection marking
in the CONNSECMARK target?
