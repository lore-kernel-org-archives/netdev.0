From: Scott Feldman <sfeldma@gmail.com>
Subject: Re: [PATCH net-next v3 0/2] iproute2: bridge vlan range support
Date: Fri, 20 Feb 2015 00:09:17 -0500
Message-ID: <CAE4R7bAG5RMP6=8KKA_W4kxAHy5vsavtccRbD5j03cSYS0a4jQ@mail.gmail.com>
References: <1422239185-14054-1-git-send-email-roopa@cumulusnetworks.com>
	<20150205104809.603763cf@urahara>
	<54E69717.3050306@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>,
	Jamal Hadi Salim <hadi@mojatatu.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f45.google.com ([209.85.216.45]:57124 "EHLO
	mail-qa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753867AbbBTFJR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 00:09:17 -0500
Received: by mail-qa0-f45.google.com with SMTP id j7so10630368qaq.4
        for <netdev@vger.kernel.org>; Thu, 19 Feb 2015 21:09:17 -0800 (PST)
In-Reply-To: <54E69717.3050306@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 9:08 PM, roopa <roopa@cumulusnetworks.com> wrote:
> On 2/5/15, 10:48 AM, Stephen Hemminger wrote:
>>
>> On Sun, 25 Jan 2015 18:26:23 -0800
>> roopa@cumulusnetworks.com wrote:
>>
>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>
>>> This series adds support for vlan ranges in iproute2 bridge add
>>> and show commands.
>>>
>>> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
>>> Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>
>>>
>>> Roopa Prabhu (2):
>>>    iproute2: bridge: support vlan range for adds
>>>    iproute2: bridge vlan show new option to print ranges
>>>
>>>   bridge/br_common.h        |    1 +
>>>   bridge/bridge.c           |    6 ++++-
>>>   bridge/vlan.c             |   55
>>> ++++++++++++++++++++++++++++++++++++++++-----
>>>   include/linux/if_bridge.h |    2 ++
>>>   include/linux/rtnetlink.h |    1 +
>>>   5 files changed, 58 insertions(+), 7 deletions(-)
>>>
>> Applied to net-next branch of iproute2
>> Go ahead and send more patches if you decide on different output format.
>
>
> Thanks stephen.
>
> Maybe too late, but wanted to add a note.
> I would have loved to have the default output print vlan ranges if the
> iproute2 version is capable and is talking to the kernel which has vlan
> range support. The netlink msg handling takes care of back ward
> compatibility.
>
> I think, I was being too cautious to not break users who might be doing
> screen scraping.
> In general should i be too worried about breaking such users ?.
> If not, I would love to resubmit the patch to make the default output print
> ranges.

+1, if not worried about breaking such users.
