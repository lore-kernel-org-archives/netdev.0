From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [ethtool PATCH 4/6] Add support for __be64 and bitops to ethtool
Date: Wed, 27 Apr 2011 11:33:28 -0700
Message-ID: <4DB86178.5090605@intel.com>
References: <20110421202857.23054.63316.stgit@gitlad.jf.intel.com>	 <20110421204035.23054.6918.stgit@gitlad.jf.intel.com>	 <1303919692.2875.11.camel@bwh-desktop>  <4DB8484F.8030001@intel.com> <1303924185.2875.48.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:21188 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753357Ab1D0Sdg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 14:33:36 -0400
In-Reply-To: <1303924185.2875.48.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/27/2011 10:09 AM, Ben Hutchings wrote:
> On Wed, 2011-04-27 at 09:46 -0700, Alexander Duyck wrote:
>> On 4/27/2011 8:54 AM, Ben Hutchings wrote:
>>> On Thu, 2011-04-21 at 13:40 -0700, Alexander Duyck wrote:
>>>> This change is meant to add support for __be64 values and bitops to
>>>> ethtool.  These changes will be needed in order to support network flow
>>>> classifier rule configuration.
> [...]
>>> Where is __always_inline supposed to be defined?
>>
>> Sorry that should have just been inline.  I forgot we have to take tools
>> other than gcc into account.
>
> Oh, it's a gcc extension?  I read the code before trying to compile it.
> I've never tested with anything other than gcc but I think it's worth
> making a small effort to avoid gcc extensions.
>
> [...]
>> On a side note, is there a git tree somewhere I can re-base off of?  At
>> this point I know you have pulled in a number of patches and I figure it
>> would be helpful for me to clean up my tree so I am not guessing what is
>> there and what isn't.
>
> git://git.kernel.org/pub/scm/network/ethtool/ethtool.git
>
> Ben.
>

I just saw the updates pushed to the tree.  Thanks.  I'll start working 
on incorporating the suggestions you made and should have an updated 
version of the remaining patches ready in the next day or so.

Thanks,

Alex
