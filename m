From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH/RFC] make MII and PHYLIB independent of NET_ETHERNET
Date: Thu, 07 Dec 2006 04:58:48 -0500
Message-ID: <4577E5D8.4010500@pobox.com>
References: <20061119202249.f0acb41c.randy.dunlap@oracle.com>	<456EBC16.8050006@pobox.com> <20061202154345.fb3b4b6a.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36122 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031930AbWLGJ6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 04:58:51 -0500
To: Randy Dunlap <randy.dunlap@oracle.com>
In-Reply-To: <20061202154345.fb3b4b6a.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Randy Dunlap wrote:
> On Thu, 30 Nov 2006 06:10:14 -0500 Jeff Garzik wrote:
> 
>> ACK, but patch doesn't apply to #upstream
> 
> Does it work to patch -mm instead?  (below)
> 
> ---
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> PHYLIB can be used by non-NET_ETHERNET (10/100 ethernet) devices;
> e.g., GIANFAR (gigabit) uses it.
> 
> We also have USB ethernet devices trying to use MII
> without NET_ETHERNET being enabled, so move MII outside of
> NET_ETHERNET, along with PHYLIB.
> 
> They both still depend on NET && NETDEVICES.
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

still didn't apply


