From: Ben Greear <greearb@candelatech.com>
Subject: Re: [BUG] RTNL and flush_scheduled_work deadlocks
Date: Thu, 15 Feb 2007 10:58:13 -0800
Message-ID: <45D4AD45.3010503@candelatech.com>
References: <20070214132729.479793ac@freekitty> <45D382B7.9020901@candelatech.com> <20070214235420.GA13816@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Kyle Lucke <klucke@us.ibm.com>,
	Raghavendra Koushik <raghavendra.koushik@neterion.com>,
	Al Viro <viro@ftp.linux.org.uk>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:35815 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030587AbXBOS7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 13:59:11 -0500
In-Reply-To: <20070214235420.GA13816@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Ben Greear <greearb@candelatech.com> :
> [...]
>> I seem to be able to trigger this within about 1 minute on a
>> particular 2.6.18.2 system with some 8139too devices, so if someone
>> has a patch that could be tested, I'll gladly test it.  For
>> whatever reason, I haven't hit this problem on 2.6.20 yet, but
>> that could easily be dumb luck, and I haven't been running .20
>> very much.
> 
> Bandaid below. It is not complete if your device hits the tx_watchdog
> hard but it should help.

So far, I've been running several hours without problems, so
this does appear to be helping.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

