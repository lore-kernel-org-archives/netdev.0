From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 07/16] net: Make /proc/net per network namespace
Date: Wed, 12 Sep 2007 03:02:11 -0700 (PDT)
Message-ID: <20070912.030211.102564635.davem@davemloft.net>
References: <m1abrwx3g0.fsf_-_@ebiederm.dsl.xmission.com>
	<m1642kx3e3.fsf_-_@ebiederm.dsl.xmission.com>
	<m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, containers@lists.osdl.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-98-Washington.hfc.comcastbusiness.net ([74.93.104.98]:35495
	"EHLO picasso.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932700AbXILKCQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 06:02:16 -0400
In-Reply-To: <m11wd8x3a3.fsf_-_@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sat, 08 Sep 2007 15:20:36 -0600

> 
> This patch makes /proc/net per network namespace.  It modifies the global
> variables proc_net and proc_net_stat to be per network namespace.
> The proc_net file helpers are modified to take a network namespace argument,
> and all of their callers are fixed to pass &init_net for that argument.
> This ensures that all of the /proc/net files are only visible and
> usable in the initial network namespace until the code behind them
> has been updated to be handle multiple network namespaces.
> 
> Making /proc/net per namespace is necessary as at least some files
> in /proc/net depend upon the set of network devices which is per
> network namespace, and even more files in /proc/net have contents
> that are relevant to a single network namespace.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Patch applied, thanks.
