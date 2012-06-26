From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [net] ixgbe: Do not pad FCoE frames as this can cause issues
 with FCoE DDP
Date: Tue, 26 Jun 2012 08:48:18 -0700
Message-ID: <4FE9D9C2.5010209@intel.com>
References: <1340696951-2686-1-git-send-email-jeffrey.t.kirsher@intel.com>  <20120626.005029.909254566674577767.davem@davemloft.net>  <1340697238.2255.20.camel@jtkirshe-mobl> <1340719768.5330.2.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, David Miller <davem@davemloft.net>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	stable@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44002 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755017Ab2FZPsU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jun 2012 11:48:20 -0400
In-Reply-To: <1340719768.5330.2.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/26/2012 07:09 AM, Ben Hutchings wrote:
> On Tue, 2012-06-26 at 00:53 -0700, Jeff Kirsher wrote:
>> On Tue, 2012-06-26 at 00:50 -0700, David Miller wrote:
>>> Sorry, quotes don't work either, what you did is still a SMTP syntax error,
>>> here's what is in the bounce I get back:
>>>
>>> 	<stable@vger.kernel.org> "[3.4]",
>>> 	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> Illegal-Object:	Syntax error in Cc: address found on vger.kernel.org:
>>> 	Cc:	<stable@vger.kernel.org>"[3.4]"
>>> 						^-missing end of address
>> Grrr...
>>
>> I will re-send without the "[3.4]", Greg will just have to deal with it.
> It's certainly not necessary to put anything like that in the real Cc
> header. Many people put something like
> 'Cc: <stable@vger.kernel.org> # 3.4' in the body; I don't know if that
> is more like likely to result in the version being stripped when
> generating mail recipients.
>
> Ben.
>
Couldn't 3.4 have been put in place of the recipient's name?  So you do
something like this:
Cc: 3.4 <stable@vger.kernel.org>

Thanks,

Alex
