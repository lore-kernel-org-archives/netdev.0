From: Michal Soltys <soltys@ziu.info>
Subject: Re: r8169 (+others ?) and note_interrupt performance hit on	2.6.30.x
Date: Sun, 26 Jul 2009 12:50:28 +0200
Message-ID: <4A6C34F4.4060709@ziu.info>
References: <4A6BA3CE.9000607@ziu.info> <20090726091803.GA28374@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:3913 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752449AbZGZKuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2009 06:50:39 -0400
In-Reply-To: <20090726091803.GA28374@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> Michal Soltys <soltys@ziu.info> :
> [...]
>> I did some quick oprofile, and noticed one new call -
>> note_interrupt - which wasn't present in the earlier kernel,
>> taking majority of the cpu time, relatively to the rest, e.g.:
>>
>> samples  cum. samples  %        cum. %     symbol name
>> 90984    90984         42.8695  42.8695    note_interrupt
> 
> May be some screaming irq.
> 
> Do your /proc/interrupts look the same with both kernels ?
> 

Yes - nothing unusual there, and amount of interrupts on the interface 
corresponds to pps. The rest is roughly idle.
