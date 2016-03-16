From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next v3 1/2] RDS: TCP: Add sysctl tunables for
 sndbuf/rcvbuf on rds-tcp socket
Date: Wed, 16 Mar 2016 07:32:11 -0400
Message-ID: <20160316113211.GC21307@oracle.com>
References: <cover.1458064902.git.sowmini.varadhan@oracle.com>
 <5c18f6bdde99628e486d63a071c256d1be036c28.1458064902.git.sowmini.varadhan@oracle.com>
 <56E93596.90503@stressinduktion.org>
 <20160316111055.GB21307@oracle.com>
 <56E942F0.90201@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	santosh.shilimkar@oracle.com, eric.dumazet@gmail.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36889 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965449AbcCPLcW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 07:32:22 -0400
Content-Disposition: inline
In-Reply-To: <56E942F0.90201@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (03/16/16 12:26), Hannes Frederic Sowa wrote:
> 
> My hope was actually that by using the ->data pointer in netns you
> don't need to provide the two functions, just simply use something
> like the following for both cases.

Ok, it would probably be less hacky to do it as you suggest.

> Do I understand it correctly that all connections of a namespace
> will be dropped if you modify those sysctls?

yes. it's unfortunate, but afaict there's no other way to make them 
use the new vars.

But as I said in the comments, an admin who goes around creating
this churn is probably doing this very rarely, and for a good
reason, and is fully aware of the cost. So there is some degree 
of human control possible.

--Sowmini
