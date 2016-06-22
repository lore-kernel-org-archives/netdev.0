From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 net-next v4 0/5] bridge: json support for fdb and
 vlan show
Date: Wed, 22 Jun 2016 10:41:52 -0700
Message-ID: <CAJieiUhRp5JWWH+Du+TSUW9Ve-jqcfHH6Zciz-EM1pmOj5Ctdw@mail.gmail.com>
References: <1466603155-53768-1-git-send-email-roopa@cumulusnetworks.com> <20160622145344.GE2068@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Anuradha Karuppiah <anuradhak@cumulusnetworks.com>,
	Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Julien Fortin <julien@cumulusnetworks.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:35193 "EHLO
	mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbcFVRly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jun 2016 13:41:54 -0400
Received: by mail-vk0-f41.google.com with SMTP id j2so71886137vkg.2
        for <netdev@vger.kernel.org>; Wed, 22 Jun 2016 10:41:53 -0700 (PDT)
In-Reply-To: <20160622145344.GE2068@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 22, 2016 at 7:53 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Jun 22, 2016 at 03:45:50PM CEST, roopa@cumulusnetworks.com wrote:
>>From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>
>>This patch series adds json support for a few bridge show commands.
>>We plan to follow up with json support for additional commands soon.
>
> I'm just curious, what is you use case for this? Apps can use rtnetlink
> socket directly.

most important use case is for automation/orchestration tools.
They use existing linux tools to query and configure. Iproute2 output
is not machine
readable today ...and json is industry standard.
