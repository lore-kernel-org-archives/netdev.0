From: Christophe Gouault <christophe.gouault@6wind.com>
Subject: Re: [PATCH iproute2 0/2] xfrm: new command for configuring SPD hash
Date: Mon, 13 Apr 2015 15:29:20 +0200
Message-ID: <CADdy8HpnJ3M-eHJ_2NdHcBksLS6BCazDn0LQym-YO1LZUdY5=Q@mail.gmail.com>
References: <1428593973-12780-1-git-send-email-christophe.gouault@6wind.com>
	<20150410132232.6010d3ff@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: shemminger@vyatta.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:34361 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbbDMN3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 09:29:21 -0400
Received: by iedfl3 with SMTP id fl3so73315542ied.1
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2015 06:29:21 -0700 (PDT)
In-Reply-To: <20150410132232.6010d3ff@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-04-10 22:22 GMT+02:00 Stephen Hemminger <stephen@networkplumber.org>:
> On Thu,  9 Apr 2015 17:39:31 +0200
> Christophe Gouault <christophe.gouault@6wind.com> wrote:
>
>> This patch adds a new command to configure the SPD hash table:
>>    ip xfrm policy set [ hthresh4 LBITS RBITS ] [ hthresh6 LBITS RBITS ]
>>
>> and code to display the SPD hash configuration:
>>    ip -s -s xfrm policy count
>>
>> The second path updates ip xfrm man page.
>>
>> Best Regards,
>> Christophe
>> --
>>  ip/xfrm_policy.c   |  105 +++++++++++++++++++++++++++++++++++++++++++++++++++++
>>  man/man8/ip-xfrm.8 |   61 ++++++++++++++++++++++++++++++++++++++++--
>>  2 files changed, 161 insertions(+), 5 deletions(-)
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> Applied to net-next branch of iproute2

Hi Stephen,

Thank you for pushing the patchset.

However it was designed for the master branch of iproute2, the feature
is available since Linux kernel v3.18 (commit 880a6fab8f6b "xfrm:
configure policy hash table thresholds by netlink").

Could you please push it to the master branch?

Best Regards,
Christophe
