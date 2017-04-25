From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH net-next 0/2] flower: add MPLS matching support
Date: Mon, 24 Apr 2017 21:48:39 -0400
Message-ID: <6ae82894-fc8b-2ad9-7dfd-cf74cd6042a1@mojatatu.com>
References: <1492894367-11637-1-git-send-email-benjamin.lahaise@netronome.com>
 <20170424.143257.1003081554810761464.davem@davemloft.net>
 <d54cca4b-6212-bf7d-93e2-8314177df42c@mojatatu.com>
 <20170424182054.116d1a99@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, benjamin.lahaise@netronome.com,
        netdev@vger.kernel.org, bcrl@kvack.org,
        Jiri Pirko <jiri@resnulli.us>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38357 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S979736AbdDYBsm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 21:48:42 -0400
Received: by mail-it0-f43.google.com with SMTP id f187so5704410ite.1
        for <netdev@vger.kernel.org>; Mon, 24 Apr 2017 18:48:42 -0700 (PDT)
In-Reply-To: <20170424182054.116d1a99@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-04-24 09:20 PM, Jakub Kicinski wrote:
> On Mon, 24 Apr 2017 20:58:18 -0400, Jamal Hadi Salim wrote:
>> On 17-04-24 02:32 PM, David Miller wrote:

>> You have 3 TLVs, one of which is u8 that only allows use of 3 bits.
>> The other is a u32 which allows only 20 bits to be set.
>
> I don't think we will ever reuse bits in a field which is called
> MPLS_LABEL for anything else than an MPLS label.

That is true. So maybe bad example. It also helps the mpls disector
wont for example allow copying of more than 20 bits for a label.

cheers,
jamal
