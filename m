From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH iproute2/net-next 0/7] tc: flower: Masked ICMP match and
 ND match
Date: Tue, 7 Feb 2017 08:52:00 +0100
Message-ID: <CAJqx_ny5A414XO8K=FGtvz6HgPQC-VWFE9h84JfGL-CDkJW0ag@mail.gmail.com>
References: <1486031920-10784-1-git-send-email-simon.horman@netronome.com> <20170206142847.3462ae48@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev <netdev@vger.kernel.org>, oss-drivers@netronome.com
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:34331 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751865AbdBGHwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:52:02 -0500
Received: by mail-lf0-f52.google.com with SMTP id v186so58112165lfa.1
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:52:02 -0800 (PST)
In-Reply-To: <20170206142847.3462ae48@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 6, 2017 at 11:28 PM, Stephen Hemminger
<stephen@networkplumber.org> wrote:
> On Thu,  2 Feb 2017 11:38:33 +0100
> Simon Horman <simon.horman@netronome.com> wrote:
>
>> Hi,
>>
>> this series have several related parts.
>>
>> * tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
>>
>>   Enhance documentation for consistency with later documentation changes.
>>
>> * tc: flower: use correct type when calling flower_icmp_attr_type
>>
>>   Type correction to ICMP code; should not have runtime effect
>>
>> * tc: flower: provide generic masked u8 parser helper
>>   tc: flower: provide generic masked u8 print helper
>>
>>   Generic parsing and printing of masked u8 options
>>
>> * tc: flower: support masked ICMP code and type match
>>
>>   Support masking ICMP code and type matches.
>>   Unmasked matching is already supported by iproute2
>>   Masked matching is already supported by the kernel.
>>
>>   This is used by the ND patches
>>
>> * tc: flower: Add TCA_FLOWER_KEY_ND_*
>>   tc: flower: Support matching on ND
>>
>> The last two patches are marked as RFC as they support functionality
>> submitted to but not yet not yet present in the kernel.
>>
>>
>> Simon Horman (7):
>>   tc: flower: Update documentation to indicate ARP takes IPv4 prefixes
>>   tc: flower: use correct type when calling flower_icmp_attr_type
>>   tc: flower: provide generic masked u8 parser helper
>>   tc: flower: provide generic masked u8 print helper
>>   tc: flower: support masked ICMP code and type match
>>   tc: flower: Add TCA_FLOWER_KEY_ND_*
>>   tc: flower: Support matching on ND
>>
>>  include/linux/pkt_cls.h |   7 ++
>>  man/man8/tc-flower.8    |  58 +++++++++--
>>  tc/f_flower.c           | 260 +++++++++++++++++++++++++++++++++++++-----------
>>  3 files changed, 258 insertions(+), 67 deletions(-)
>>
>
> Since this patchset depended on changes to pkt_cls.h which are not accepted upstream
> into net-next, I marked it as awaiting upstream.  When the corresponding kernel changes
> are accepted into net-next please resubmit it.

Hi Stephen,

I think that the first 5 patches can be considered independently of
the last two which have the dependency you describe. Sorry for not
making this clearer; e.g. by posting them separately. Would it help if
I reposted the first five patches?
