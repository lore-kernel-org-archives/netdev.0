From: Jonathan Toppins <jtoppins@cumulusnetworks.com>
Subject: Re: [PATCH net-next 0/5] bonding: various 802.3ad fixes
Date: Mon, 19 Jan 2015 15:39:00 -0500
Message-ID: <54BD6B64.2010505@cumulusnetworks.com>
References: <1421423848-414-1-git-send-email-jtoppins@cumulusnetworks.com> <54BD5B0B.5030507@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: Nikolay Aleksandrov <nikolay@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f173.google.com ([209.85.216.173]:40401 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751590AbbASUjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 15:39:03 -0500
Received: by mail-qc0-f173.google.com with SMTP id m20so16899699qcx.4
        for <netdev@vger.kernel.org>; Mon, 19 Jan 2015 12:39:02 -0800 (PST)
In-Reply-To: <54BD5B0B.5030507@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/15 2:29 PM, Nikolay Aleksandrov wrote:
> On 01/16/2015 04:57 PM, Jonathan Toppins wrote:
>> This patch series is a forward porting of patches we (Cumulus) are shipping
>> in our 3.2 series kernels. These fixes attempt to make 802.3ad bonding mode
>> more predictable in certian state machine transtions in addition to enhancing
>> 802.3ad bond carrier determination based on acutal number of peered ports plus
>> if the bond has an active aggregrator. Specific notes are contained within each
>> patch.
>>
>> For this patch series there are no userspace facing changes, a diff between
>> the modinfo output showed no difference. However, there are behavioral
>> facing changes, primarily in the bond carrier state. Please make sure to
>> review carefully.
>>
>> Jonathan Toppins (1):
>>    bonding: cleanup and remove dead code
>>
>> Satish Ashok (1):
>>    bonding: fix LACP PDU not sent on slave port sometimes
>>
>> Scott Feldman (1):
>>    bonding: keep bond interface carrier off until at least one active
>>      member
>>
>> Wilson Kok (2):
>>    bonding: fix bond_open() don't always set slave active flag
>>    bonding: fix incorrect lacp mux state when agg not active
>>
>>   drivers/net/bonding/bond_3ad.c     |   73 ++++++++++++++++++++++++++++--------
>>   drivers/net/bonding/bond_main.c    |    6 +--
>>   drivers/net/bonding/bond_options.c |    1 +
>>   include/net/bond_3ad.h             |    1 -
>>   include/net/bonding.h              |    1 +
>>   5 files changed, 62 insertions(+), 20 deletions(-)
>>
>
> Hi Jonathan,
> For all patches you should also CC the other maintainers of the bonding -
> Jay and Veaceslav, I'm adding them now just in case they've missed them.
> I have a few cosmetic nits which I don't have a strong feeling about i.e.
> if the others are okay with them - then ignore them, I've replied to the
> patches directly, but other than that you can add for the set my:
>
> Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
>

Hi Nikolay,
Appreciate the review... looking over comments now. Apologies for not 
including other maintainers, will make sure to include them in v2 of 
patch series.
