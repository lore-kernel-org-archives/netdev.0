From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: atl1 transmit timeout Was: Re: oops/warning report for the week
 of November 26, 2008
Date: Fri, 28 Nov 2008 13:22:31 -0800
Message-ID: <49306117.3030909@linux.intel.com>
References: <492DD792.6080302@linux.intel.com>	<20081128111827.79b12739@osprey.hogchain.net>	<20081128093217.3888fb46@linux.intel.com>	<20081128123631.5209d0b8@osprey.hogchain.net>	<20081128105044.241d43c0@linux.intel.com> <20081128151207.3999a097@osprey.hogchain.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Jay Cliburn <jcliburn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:44153 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752364AbYK1VWj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 16:22:39 -0500
In-Reply-To: <20081128151207.3999a097@osprey.hogchain.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Cliburn wrote:
> On Fri, 28 Nov 2008 10:50:44 -0800
> Arjan van de Ven <arjan@linux.intel.com> wrote:
> 
>> => select count(version), version from oopses where
>> guilty='dev_watchdog(atl1)' group by version order by version desc;
>> count |     version -------+-----------------
>>     93 | 2.6.27.5
>>      6 | 2.6.27.4
>>      1 | 2.6.27.3
>>      1 | 2.6.27.2
>>      1 | 2.6.27-rc9
>>      1 | 2.6.27-rc7-git1
>>      1 | 2.6.27-rc7
>>      1 | 2.6.27-rc6
>>      6 | 2.6.27-rc3
>>      7 | 2.6.27
>>      4 | 2.6.26.6
>> (11 rows)
> 
> Wow.  4 hits in 2.6.26, then 118 in 2.6.27.
> 
> A history of changes between 2.6.26 and 2.6.27.5 shows a mere six
> changes to the driver.

one thing to note is that for the .26 kernel, there was not very good data collection of this issue yet.
(Although.. more than 4% I would say; Fedora had the patches to report the driver info backported for quite some time)

