From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v2 net-next 1/5] bpf: Refactor cgroups code in prep for
 new type
Date: Sun, 13 Nov 2016 20:51:59 -0700
Message-ID: <65b46edc-02bd-415c-4b1d-af36928d22da@cumulusnetworks.com>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
 <1477529922-4806-2-git-send-email-dsa@cumulusnetworks.com>
 <20161031.125801.874510216543796824.davem@davemloft.net>
 <542e0d3e-2f57-96f9-1da1-b71e2c970395@zonque.org>
 <44b37825-d001-c708-963f-cbdedb559710@cumulusnetworks.com>
 <7d2a099d-1039-ef2d-86e6-2fca151d316c@zonque.org>
 <20161031174942.GF32374@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        ast@fb.com, daniel@iogearbox.net, maheshb@google.com
To: Thomas Graf <tgraf@suug.ch>, Daniel Mack <daniel@zonque.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:34519 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752801AbcKND5u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 22:57:50 -0500
Received: by mail-pg0-f43.google.com with SMTP id x23so46046651pgx.1
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 19:57:50 -0800 (PST)
In-Reply-To: <20161031174942.GF32374@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 11:49 AM, Thomas Graf wrote:
> On 10/31/16 at 06:16pm, Daniel Mack wrote:
>> On 10/31/2016 06:05 PM, David Ahern wrote:
>>> On 10/31/16 11:00 AM, Daniel Mack wrote:
>>>> Yeah, I'm confused too. I changed that name in my v7 from 
>>>> BPF_PROG_TYPE_CGROUP_SOCK to BPF_PROG_TYPE_CGROUP_SKB on David's
>>>> (Ahern) request. Why is it now renamed again?
>>>
>>> Thomas pushed back on adding another program type in favor of using
>>> subtypes. So this makes the program type generic to CGROUP and patch
>>> 2 in this v2 set added Mickaël's subtype patch with the socket
>>> mangling done that way in patch 3.
>>>
>>
>> Fine for me. I can change it around again.
> 
> I would like to hear from Daniel B and Alexei as well. We need to
> decide whether to use subtypes consistently and treat prog types as
> something more high level or whether to bluntly introduce a new prog
> type for every distinct set of verifier limits. I will change lwt_bpf
> as well accordingly.
> 

Alexei / Daniel - any comments/preferences on subtypes vs program types?
