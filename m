From: Rick Jones <rick.jones2@hp.com>
Subject: Re: 2.6.24 BUG: soft lockup - CPU#X
Date: Wed, 26 Mar 2008 10:31:34 -0700
Message-ID: <47EA8876.5000104@hp.com>
References: <47EA7DE8.9070203@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Matheos Worku <Matheos.Worku@Sun.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:8091 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753626AbYCZRbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2008 13:31:37 -0400
In-Reply-To: <47EA7DE8.9070203@sun.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matheos Worku wrote:
> All,
> 
> While running iperf (transmit) on NIU driver I get several soft lockup 
> errors.  I have seen similar soft lockup errors on kernels 2.6.18 and 
> later (with other 10G NIC drivers with LSO disabled) but it is more 
> frequent/pronounced on 2.6.24 kernel.  oprofile is not giving  much clue 
> as where the cpus are spending time (atleast doesn't indicate any thing 
> abnormal in the driver(s)). 

Is oprofile running on an AMD processor able to profile where/when 
interrupts are disabled?  If not there could be a fair bit missing from 
the profile.

rick jones
