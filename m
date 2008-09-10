From: Chris Snook <csnook@redhat.com>
Subject: Re: Suggested patch: Sending the FQDN when booting via DHCP
Date: Tue, 09 Sep 2008 23:16:37 -0400
Message-ID: <48C73C15.2000103@redhat.com>
References: <48C6B3DA.3040904@wanadoo.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Thierry <thierry.bultel@wanadoo.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:43003 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751949AbYIJDSJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 23:18:09 -0400
In-Reply-To: <48C6B3DA.3040904@wanadoo.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thierry wrote:
> [re-sent without HTML encoding, and to the right aliases ...]
> 
> Hi all,
> 
> the following patch can be useful, in order to let the DHCP server 
> accordingly update the DNS, when booting via DHCP.
> 
> This can be useful for 2 reasons:
> 1) on small systems, the embedded filesystem may even not have udhcpd
> 2) when booting nfsroot, the nfs server does not like when udhcpd in 
> invoked, even when requested the same IP address.
> 
> Here is the patch, for 2.6.27-rc5. (Notice that it is the very first 
> time I deliver a patch for Linux, and I may
> have missed some points on the procedure, if it is the case I apologize 
> for that). What do you think about it ?
> 
> Any ideas or comments are welcome.

This should probably be a kernel command-line option, rather than a static 
config option.

-- Chris
