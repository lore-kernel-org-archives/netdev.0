From: Andy <andy@globalnetit.com>
Subject: Re: reminder, 2.6.18 window...
Date: Wed, 24 May 2006 16:53:21 -0400
Message-ID: <1148504001.29448.574.camel@tahini.andynet.net>
References: <20060523.182217.59656237.davem@davemloft.net>
	<447412CA.50303@ipom.com>  <4474A489.4080308@garzik.org>
Reply-To: andy@globalnetit.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Phil Dibowitz <phil@ipom.com>, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from vms042pub.verizon.net ([206.46.252.42]:19944 "EHLO
	vms042pub.verizon.net") by vger.kernel.org with ESMTP
	id S932369AbWEXUxh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 May 2006 16:53:37 -0400
Received: from andyhp.tranquilitynj.net ([141.150.89.24])
 by vms042.mailsrvcs.net
 (Sun Java System Messaging Server 6.2-4.02 (built Sep  9 2005))
 with ESMTPA id <0IZS00MLCFDCWMJ0@vms042.mailsrvcs.net> for
 netdev@vger.kernel.org; Wed, 24 May 2006 15:53:37 -0500 (CDT)
In-reply-to: <4474A489.4080308@garzik.org>
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-05-24 at 14:23 -0400, Jeff Garzik wrote:

> I disagree that we should bother about clearing statistics.  It always 
> adds more complication than necessary.  Few (if any) other statistics in 
> Linux permit easy clearing, 

iptables -Z

> often because adding operations other than 
> 'increment' or 'read' requires adding expensive spinlocks or atomic 
> operations.

Why is 'set to N' so different from 'increment'?

- Andy


