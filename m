From: roopa <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] iproute2: bridge: support vlan range
Date: Sun, 18 Jan 2015 19:06:46 -0800
Message-ID: <54BC74C6.6070702@cumulusnetworks.com>
References: <1421391147-35021-1-git-send-email-roopa@cumulusnetworks.com> <CAE4R7bA2VHepe8CCYuubH8teXMvRry10jnpsisYq+7Qv+gXzHQ@mail.gmail.com> <54BB78DA.6060208@cumulusnetworks.com> <CAE4R7bA6f-f9zTL4iKn11xAWD7evbEGMb+b8zgrm780Hx0yg4w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, shemminger@vyatta.com,
	"vyasevic@redhat.com" <vyasevic@redhat.com>,
	Wilson Kok <wkok@cumulusnetworks.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:43768 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750953AbbASDGs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 22:06:48 -0500
Received: by mail-pa0-f43.google.com with SMTP id lj1so10188998pab.2
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 19:06:47 -0800 (PST)
In-Reply-To: <CAE4R7bA6f-f9zTL4iKn11xAWD7evbEGMb+b8zgrm780Hx0yg4w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/18/15, 9:44 AM, Scott Feldman wrote:
> On Sun, Jan 18, 2015 at 1:11 AM, roopa <roopa@cumulusnetworks.com> wrote:
>> On 1/17/15, 5:35 PM, Scott Feldman wrote:
>>> On Thu, Jan 15, 2015 at 10:52 PM,  <roopa@cumulusnetworks.com> wrote:
>>>> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>>>>
>>>> This patch adds vlan range support to bridge command
>>>> using the newly added vinfo flags BRIDGE_VLAN_INFO_RANGE_BEGIN and
>>>> BRIDGE_VLAN_INFO_RANGE_END.
>>>>
>>>> +                               vinfo.flags |=
>>>> BRIDGE_VLAN_INFO_RANGE_BEGIN;
>>>> +                       } else {
>>>> +                               vinfo.vid = atoi(*argv);
>>>> +                       }
>>>>                   } else if (strcmp(*argv, "self") == 0) {
>>>>                           flags |= BRIDGE_FLAGS_SELF;
>>>>                   } else if (strcmp(*argv, "master") == 0) {
>>>> @@ -67,7 +78,7 @@ static int vlan_modify(int cmd, int argc, char **argv)
>>>>                   argc--; argv++;
>>>>           }
>>>>
>>>> -       if (d == NULL || vid == -1) {
>>>> +       if (d == NULL || vinfo.vid == -1) {
>>> Where was vinfo.vid initialized to -1?  Maybe use vid rather than
>>> vinfo.vid in the code above where parsing the arg, and continue using
>>> vid and vid_end until final put of vinfo.
>>>
>> There is already a "memset(&vinfo, 0, sizeof(vinfo));"  in the code in the
>> beginning of the function.
> That's the problem...vinfo.vid is initialized to 0, not -1, so
> checking if vinfo.vid == -1 is always false.

ack, v2 coming ... thanks
