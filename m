From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Refactor Netlink connector?
Date: Wed, 31 May 2006 05:00:46 +0200
Message-ID: <20060531030046.GC7844@postel.suug.ch>
References: <Pine.LNX.4.64.0605261552570.4856@d.namei> <20060527134629.GA16306@2ka.mipt.ru> <Pine.LNX.4.64.0605271223390.12872@d.namei> <Pine.LNX.4.64.0605271303050.13104@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Smalley <sds@tycho.nsa.gov>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:31892 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1751580AbWEaDA0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 23:00:26 -0400
To: James Morris <jmorris@namei.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0605271303050.13104@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* James Morris <jmorris@namei.org> 2006-05-27 13:21
> Actually, a possible solution here is to completely remove all internal 
> knowledge of netlink messages from SELinux and have the netfilter 
> framework and protocols provide methods to determine message types and 
> permissions.

Right, regarding generic netlink we can extend struct genl_ops to
include a policy stating what permissions are required. Besides
that we can extend struct nla_policy to support validating of
attributes.
