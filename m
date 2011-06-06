From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 16:49:22 -0600
Message-ID: <4DED5972.6020507@genband.com>
References: <20110606.122217.2183968212149987796.davem@davemloft.net>	<1307390721.8149.2763.camel@tardy>	<17839.1307394369@death> <20110606.144026.1544243502220840783.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: fubar@us.ibm.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og113.obsmtp.com ([64.18.2.179]:55312 "EHLO
	exprod7og113.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758405Ab1FFWt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 18:49:29 -0400
In-Reply-To: <20110606.144026.1544243502220840783.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/06/2011 03:40 PM, David Miller wrote:
> From: Jay Vosburgh<fubar@us.ibm.com>
> Date: Mon, 06 Jun 2011 14:06:09 -0700
>
>> 	Right, the common use case for balance-rr (round robin) is to
>> maximize TCP throughput for one connection, over a set of whatever
>> network devices are available (or are cheap) by striping that connection
>> across multiple interfaces.  The tcp_reordering sysctl is set to some
>> large value so that TCP will deal with the reordering as best it can.
>
> FWIW, I really would never, ever, encourage schemes like this.  Even
> if they do happen to work.

Why not?  And if not then what's the recommended way to handle the above 
scenario?  (Assuming hardware upgrade isn't an option.)

Chris

-- 
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
