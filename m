From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cipso: handle CIPSO options correctly when NetLabel
 is disabled
Date: Fri, 01 Jun 2012 14:18:10 -0400 (EDT)
Message-ID: <20120601.141810.1973076676004541876.davem@davemloft.net>
References: <20120601155456.5114.68007.stgit@sifl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-security-module@vger.kernel.org
To: pmoore@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932410Ab2FASSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 14:18:12 -0400
In-Reply-To: <20120601155456.5114.68007.stgit@sifl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <pmoore@redhat.com>
Date: Fri, 01 Jun 2012 11:54:56 -0400

> When NetLabel is not enabled, e.g. CONFIG_NETLABEL=n, and the system
> receives a CIPSO tagged packet it is dropped (cipso_v4_validate()
> returns non-zero).  In most cases this is the correct and desired
> behavior, however, in the case where we are simply forwarding the
> traffic, e.g. acting as a network bridge, this becomes a problem.
> 
> This patch fixes the forwarding problem by providing the basic CIPSO
> validation code directly in ip_options_compile() without the need for
> the NetLabel or CIPSO code.  The new validation code can not perform
> any of the CIPSO option label/value verification that
> cipso_v4_validate() does, but it can verify the basic CIPSO option
> format.
> 
> The behavior when NetLabel is enabled is unchanged.
> 
> CC: stable@vger.kernel.org
> Signed-off-by: Paul Moore <pmoore@redhat.com>
> 

I like this a lot better, applied, thanks Paul.
