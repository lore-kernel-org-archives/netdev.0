From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [1/1] netchannel subsystem.
Date: Tue, 16 May 2006 11:15:37 +0400
Message-ID: <20060516071537.GA23843@2ka.mipt.ru>
References: <20060516061909.GA28670@2ka.mipt.ru> <20060515.235712.26771832.davem@davemloft.net> <20060516065923.GA8649@2ka.mipt.ru> <20060516.000631.12029052.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:59536 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1751651AbWEPHPt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 May 2006 03:15:49 -0400
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060516.000631.12029052.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 16, 2006 at 12:06:31AM -0700, David S. Miller (davem@davemloft.net) wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Tue, 16 May 2006 10:59:23 +0400
> 
> > And what if we use ESP which would place it's hashed sequence number as
> > port?
> 
> If it makes you happy put something like:
> 
> 	case TCP:
> 	case UDP:
> 	case SCTP:
> 	case DCCP:
> 	     ...
> 
> 	default:
> 	     ...

That makes sence, but from the other point we loose ability to drop
packet early while checking it's header for correct checksum, sizes and
so on...

-- 
	Evgeniy Polyakov
