From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Subject: Re: [PATCH] ipv4: add DiffServ priority based routing
Date: Thu, 11 Mar 2010 12:32:56 -0700
Message-ID: <4B994568.4010003@redfish-solutions.com>
References: <4B4CE2B8.1040702@redfish-solutions.com>	<20100112.130355.144803575.davem@davemloft.net>	<4B9943A4.8040606@redfish-solutions.com> <20100311.112941.177105216.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: torsten.schmidt@s2006.tu-chemnitz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:35272 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754729Ab0CKTdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Mar 2010 14:33:00 -0500
In-Reply-To: <20100311.112941.177105216.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2010 12:29 PM, David Miller wrote:
> From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
> Date: Thu, 11 Mar 2010 12:25:24 -0700
> 
>> I agree with the notion that certain values should be set side-wide
>> (or at least system-wide) to prevent malicious users from exploiting
>> QoS...  that's why I've been advocating for QoS settings to be
>> specified in a system configuration file, and not a per-user
>> configuration file.
> 
> So I can set whatever I want on my personal workation.
> 
> I'm sure sysadmins will be happy about that.
> 
> Look, this doesn't work.  QoS handling and policy belongs in the
> egress point to the network, it's the only way to control this
> properly and prevent abuse.


Well, anyone who has 'root' on their workstation can already do a fair amount of damage on a network... we're not letting any new genies out of the bottle... we're just giving them more room to stretch.

"QoS handling and policy belongs in the egress point to the network, it's the only way to control this properly and prevent abuse."

Except that it doesn't.  As I pointed out in another email, TFTP, FTP-Data, and RTP are very hard to categorize correctly.

For that matter, so is SSH, since it can be an interactive shell session, an SCP file transfer, or a mix of various tunneled protocols like X and LPR.

So by the time packets get to the egress point, oftentimes you've lost sufficient information to adequately categorize them.

