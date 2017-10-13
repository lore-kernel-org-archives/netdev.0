From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next v2 1/1] bridge: return error code when deleting
 Vlan
Date: Fri, 13 Oct 2017 08:31:42 -0600
Message-ID: <fd85d139-f727-6ef7-ceec-8b6dba961bca@gmail.com>
References: <1507816314-2896-1-git-send-email-mrv@mojatatu.com>
 <fef6f65d-473c-ee8e-51cc-1382cb6f84b9@gmail.com>
 <CAHvchGnVZaSq+s9953jdbf6-UzDFb36457U6Pk0oQHgVOKwzQg@mail.gmail.com>
 <e4611694-4248-e796-5cca-24f3d07e0e9e@cumulusnetworks.com>
 <64292550-f043-c1f7-5b0e-004288832887@mojatatu.com>
 <ba70b4c0-2bd9-9722-7101-e823d901f09f@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Roman Mashak <mrv@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:53571 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758063AbdJMObl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 10:31:41 -0400
Received: by mail-pf0-f178.google.com with SMTP id t188so7976000pfd.10
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 07:31:41 -0700 (PDT)
In-Reply-To: <ba70b4c0-2bd9-9722-7101-e823d901f09f@cumulusnetworks.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/17 8:15 PM, Nikolay Aleksandrov wrote:
> I do agree it's a bug, but there might be scripts that rely on it and
> don't check the return value when clearing vlans. They will end up with
> a partial clear and wrongly assumed state, so maybe leave the
> opportunistic delete but count if anything was actually deleted and send
> an event only then ?

+1
