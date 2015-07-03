From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH] rtnetlink: Actually use the policy for the IFLA_VF_INFO
Date: Fri, 03 Jul 2015 23:52:25 +0200
Message-ID: <55970419.804@iogearbox.net>
References: <20150630225255.GA22529@obsidianresearch.com> <5593B48F.2060403@iogearbox.net> <5594F7AE.3010704@iogearbox.net> <20150702230630.GA26691@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Jiri Pirko <jiri@resnulli.us>, Thomas Graf <tgraf@suug.ch>,
	"David S. Miller" <davem@davemloft.net>,
	Chris Wright <chrisw@sous-sol.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40452 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755389AbbGCVw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jul 2015 17:52:28 -0400
In-Reply-To: <20150702230630.GA26691@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/03/2015 01:06 AM, Jason Gunthorpe wrote:
> On Thu, Jul 02, 2015 at 10:34:54AM +0200, Daniel Borkmann wrote:
>>> So, commit c02db8c6290b moved it into a nested attribute (IFLA_VF_INFO)
>>> where we indeed don't do further validation. Imho, we should pass the
>>> parsed attribute table from nla_parse_nested() down into do_setvfinfo(),
>>> something like the below; I can give it a test run on my ixgbe.
>>
>> Sorry for the late reply, something like this looks good from my side.
>
> Okay, since it is your patch, will you send it to DaveM with my
> Reported-By?

Either way is fine by me, if you prefer, you can also just update your
initial submission. In any case, we should get it fixed eventually.

Thanks,
Daniel
