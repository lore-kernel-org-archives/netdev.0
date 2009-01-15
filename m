From: Ben Greear <greearb@candelatech.com>
Subject: Re: Bad tg3 performance on S10 netbook
Date: Wed, 14 Jan 2009 16:07:58 -0800
Message-ID: <496E7E5E.8010708@candelatech.com>
References: <496E64BB.7080709@candelatech.com> <20090114234745.GA23993@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33768 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755474AbZAOAIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 19:08:00 -0500
In-Reply-To: <20090114234745.GA23993@xw6200.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Carlson wrote:

>> Thanks,
>> Ben
> 
> Does the following patch fix the problem?

It does seem to fix the rx-miss.  Our application still runs
sub-optimal until we do something that uses lots of CPU, but
at least the NIC doesn't appear to be dropping packets now.

I tested this patch on the standard tg3 in the 2.6.25.20 kernel,
btw.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

