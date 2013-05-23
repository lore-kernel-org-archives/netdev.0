From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] ipv4: netfilter: always let NUL terminated string ended
 by '\0'
Date: Thu, 23 May 2013 13:08:32 +0200
Message-ID: <20130523110832.GB22553@localhost>
References: <5195ECB3.5000006@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52836 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758359Ab3EWLJD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 May 2013 07:09:03 -0400
Content-Disposition: inline
In-Reply-To: <5195ECB3.5000006@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 17, 2013 at 04:39:15PM +0800, Chen Gang wrote:
> 
> For NUL terminated string, better always be sure of ended by '\0'.
> 
> 'pm' is 'struct ulog_packet_msg_t' which may be copied to user mode
> (defined in "include/uapi/..."), so can not use strlcpy() instead of.

loginfo->prefix is always nul-terminated, as this is validated in
checkentry. I don't think the kernel will take a non nul-terminated
device name either.
