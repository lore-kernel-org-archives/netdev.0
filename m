From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: pull request: wireless-next 2012-05-03
Date: Fri, 4 May 2012 10:57:05 +0200
Message-ID: <4FA399E1.5080708@broadcom.com>
References: <20120503152206.GL9285@tuxdriver.com>
 <20120503.130516.1008806127286088740.davem@davemloft.net>
 <20120503.131707.112550136096227430.davem@davemloft.net>
 <1336066186.13866.25.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "Joe Perches" <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1150 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753056Ab2EDI5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2012 04:57:18 -0400
In-Reply-To: <1336066186.13866.25.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/03/2012 07:29 PM, Joe Perches wrote:
> On Thu, 2012-05-03 at 13:17 -0400, David Miller wrote:
>>  ...
>> -		if (hdev->discovery.type == DISCOV_TYPE_INTERLEAVED) {
>> +		if (hdev->discovery.type == DISCOV_TYPE_INTERLEAVED &&
>> +				hdev->discovery.state == DISCOVERY_FINDING) {
>>
>> Really, we went through this a million times very recently and I'm
>> not pulling anything into my tree that has garbage like this in it.
> 
> Perhaps the bluetooth folk can adopt using
> 
> scripts/checkpatch.pl --strict
> 
> or maybe checkpatch could be changed to use
> --strict on patches in net and drivers/net
> automatically.

When the --strict option was added it made me wonder if that meant we
should add this option in Documentation/SubmittingPatches. I do not see
why the patches for net subsystem should have a different check level.
So why not do --strict by default and get rid of the option flag.

Gr. AvS
