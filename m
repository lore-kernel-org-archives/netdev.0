From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: reminder, 2.6.18 window...
Date: Thu, 25 May 2006 12:53:57 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0605251249500.29593@netcore.fi>
References: <20060523.182217.59656237.davem@davemloft.net> <447412CA.50303@ipom.com>
 <4474A489.4080308@garzik.org> <20060524185644.GF22881@ipom.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:40113 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S965098AbWEYJyq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 05:54:46 -0400
To: Phil Dibowitz <phil@ipom.com>
In-Reply-To: <20060524185644.GF22881@ipom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 24 May 2006, Phil Dibowitz wrote:
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

AFAIK, note that clearing interface statistics on such routers doesn't 
clear SNMP statistics, just the statistics available through CLI.  So 
you really have two levels of statistics, and I suspect clearing 
"slave" statistics shouldn't be too difficult to implement.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
