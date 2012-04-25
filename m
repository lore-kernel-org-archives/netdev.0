From: Prasanna Panchamukhi <ppanchamukhi@riverbed.com>
Subject: Re: [net 1/2] e1000e: MSI interrupt test failed, using legacy interrupt
Date: Wed, 25 Apr 2012 15:46:00 -0700
Message-ID: <4F987EA8.6090700@riverbed.com>
References: <1335333314-6814-1-git-send-email-jeffrey.t.kirsher@intel.com>	 <1335333314-6814-2-git-send-email-jeffrey.t.kirsher@intel.com> <1335369547.2602.3.camel@bwh-desktop.uk.solarflarecom.com>
Reply-To: prasanna.panchamukhi@riverbed.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.riverbed.com ([208.70.196.44]:47925 "EHLO
	smtp2.riverbed.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932274Ab2DYWqA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 18:46:00 -0400
In-Reply-To: <1335369547.2602.3.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/25/2012 08:59 AM, Ben Hutchings wrote:
> On Tue, 2012-04-24 at 22:55 -0700, Jeff Kirsher wrote:
>> From: Prasanna S Panchamukhi<ppanchamukhi@riverbed.com>
>>
>> Following logs where seen on Systems with multiple NICs,
>> while using MSI interrupts as shown below:
> [...]
>> This patch fixes this problem by increasing the msleep from 50 to 100.
> [...]
>
> It probably doesn't, in general.  The out-of-tree version of the sfc
> driver used to perform an interrupt test during probe, and after fixing
> it up repeatedly I eventually had to remove it completely as there are
> so many ways to get a false negative.  Also see the related commit
> 93e5dfa59b0e26a145a8adce5c9edf50bdaef4c7 ('sfc: Raise self-test
> timeouts').
>
Thanks Ben for your review.
In general Ben's approach looks good fix to avoid false negatives. To 
give a little
bit of background, this issues is seen mostly with Intel 82571 Dual/quad 
port Gigabit ethernet controller add-on NICs and not seen with other 
Intel ethernet controller NICs. If Ben suggested
approach is the best way to go, I will provide a patch  soon.

Thanks,
Prasanna

> Ben.
>
