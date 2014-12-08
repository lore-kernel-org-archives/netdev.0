From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v5 0/3] remove bridge mode BRIDGE_MODE_SWDEV
Date: Mon, 08 Dec 2014 15:00:01 -0800
Message-ID: <54862D71.6060703@cumulusnetworks.com>
References: <1418076261-24593-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bBUDQztn-Pk-xRxVJbGbnjE2_CnyDn3-k3PWPUu7mFJsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?SmnFmcOtIFDDrXJrbw==?= <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Benjamin LaHaise <bcrl@kvack.org>, Thomas Graf <tgraf@suug.ch>,
	john fastabend <john.fastabend@gmail.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	John Linville <linville@tuxdriver.com>,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"shm@cumulusnetworks.com" <shm@cumulusnetworks.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:56124 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbaLHXAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Dec 2014 18:00:14 -0500
In-Reply-To: <CAE4R7bBUDQztn-Pk-xRxVJbGbnjE2_CnyDn3-k3PWPUu7mFJsw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/8/14, 2:49 PM, Scott Feldman wrote:
> Roopa, thanks for fixing this.  I'm a little lost on status of the
> iproute2 patches related to this change and earlier changes.  Would
> you and Jiri respin one set of iproute2 patches that gets us the final
> answer?  It was getting a little messy with patches on top of
> yet-to-be-accepted patches.  Thanks.
scott, the iproute2 v3 patch was the last (hopefully final) patch and 
jiri and you signed-off on that
Its here:
http://patchwork.ozlabs.org/patch/418350/

Thanks for the review.

>
> On Mon, Dec 8, 2014 at 2:04 PM,  <roopa@cumulusnetworks.com> wrote:
>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> BRIDGE_MODE_SWDEV was introduced to indicate switchdev offloads
>> for bridging from user space (In other words to call into the hw switch
>> port driver directly). But user can use existing BRIDGE_FLAGS_SELF
>> to call into the hw switch port driver today. swdev mode is not required
>> anymore. So, this patch removes it.
>>
>> v4 - v5
>>      incorporate comments
>>      - Define BRIDGE_MODE_UNDEF to handle cases where mode is not defined
>>      - reverse the order of patches
>>      - include patch comments in all patches
>>
>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>> Roopa Prabhu (3):
>>    bridge: new mode flag to indicate mode 'undefined'
>>    rocker: remove swdev mode
>>    bridge: remove mode 'swdev'
>>
>>   drivers/net/ethernet/rocker/rocker.c |   18 +-----------------
>>   include/uapi/linux/if_bridge.h       |    2 +-
>>   net/core/rtnetlink.c                 |   10 ++++++++--
>>   3 files changed, 10 insertions(+), 20 deletions(-)
>>
>> --
>> 1.7.10.4
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
