From: Jeff Garzik <jeff@garzik.org>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 15:05:54 -0400
Message-ID: <4474AE92.3030501@garzik.org>
References: <20060523.182217.59656237.davem@davemloft.net> <447412CA.50303@ipom.com> <4474A489.4080308@garzik.org> <20060524185644.GF22881@ipom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:47497 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750779AbWEXTF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 May 2006 15:05:58 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <20060524185644.GF22881@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Phil Dibowitz wrote:
> On Wed, May 24, 2006 at 02:23:05PM -0400, Jeff Garzik wrote:
>> I disagree that we should bother about clearing statistics.  It always 
>> adds more complication than necessary.  Few (if any) other statistics in 
>> Linux permit easy clearing, often because adding operations other than 
>> 'increment' or 'read' requires adding expensive spinlocks or atomic 
>> operations.
> 
> Every networking device in the world supports clearing interface statistics.
> Why should linux not be able to do the most basic operation on any
> cisco/juniper/enterasys/whatever managed switch or router?
> 
> It's a common operation on a network interface, I don't see why this is a
> concern.
> 
> When I'm debugging a networking issue On a cluster of hundreds and hundreds
> of machines at work, I want to be able to reset them all quickly, and get a
> rough idea of if they're all climbing, if they're all climbing at the same
> rate, etc. And being able to do "for i in `cat hostlist`; do ssh $i ethtool -z
> eth0; done" is really, really, REALLY, useful.

Obtaining the difference between two numbers is not that difficult.

Given any method of clearing statistics across your cluster, I'm certain 
you can come up with a similar method of obtaining the current statistic 
(the baseline).

	Jeff



