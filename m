From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb and
 vlan show
Date: Thu, 23 Jun 2016 04:03:28 -0700
Message-ID: <CAJieiUjUy-uhw=fONKvsnaHEu_8WcLiJhBL30Aze8F4_-d2gww@mail.gmail.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com>
 <20160622145344.GE2068@nanopsycho.orion> <20160622111047.1523b06f@xeon-e3> <20160622200055.GA1977@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Julien Fortin <julien@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f51.google.com ([209.85.213.51]:36211 "EHLO
	mail-vk0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751654AbcFWLDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 07:03:30 -0400
Received: by mail-vk0-f51.google.com with SMTP id u64so100444635vkf.3
        for <netdev@vger.kernel.org>; Thu, 23 Jun 2016 04:03:30 -0700 (PDT)
In-Reply-To: <20160622200055.GA1977@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 1:00 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Jun 22, 2016 at 08:10:47PM CEST, stephen@networkplumber.org wrote:
>>On Wed, 22 Jun 2016 16:53:44 +0200
>>Jiri Pirko <jiri@resnulli.us> wrote:
>>
>>> Wed, Jun 22, 2016 at 03:45:50PM CEST, roopa@cumulusnetworks.com wrote:
>>> >From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> >
>>> >This patch series adds json support for a few bridge show commands.
>>> >We plan to follow up with json support for additional commands soon.
>>>
>>> I'm just curious, what is you use case for this? Apps can use rtnetlink
>>> socket directly.
>>
>>Try using netlink in perl or python, it is quite difficult.
>
> pyroute2? Quite easy...

none of the implementations out there are complete nor can compete
with iproute2.
iproute2 is maintained by netdev community and always is up-todate
with the latest
networking api.

Nothing against pyroute2 but we wrote our own for other reasons and we
carry additional burden of maintaining it and keeping it up-todate for
every networking api..
that gets added to iproute2 (and the implementation of netlink
is often very easy in C).

Also, for external automation and orchestration tools (to whom this
patch-set is addressed),
there is no reason for them to write and maintain their own tools
using netlink when they
can use iproute2 directly to create a link or query its properties.
