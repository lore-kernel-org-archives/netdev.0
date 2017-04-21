From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net: heap out-of-bounds in
 fib6_clean_node/rt6_fill_node/fib6_age/fib6_prune_clone
Date: Fri, 21 Apr 2017 09:47:18 -0700
Message-ID: <1492793238.6453.30.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CACT4Y+YrA45diWz_8f4St8oX6aTC1kuGXMUvniGRbqXSGwawZQ@mail.gmail.com>
         <2270c1ca-9481-60c1-9c29-87669223bded@cumulusnetworks.com>
         <CACT4Y+aUROZgAczRfntp5Rgvzcypviz5ZWBPdE6MWSiO0-3jEg@mail.gmail.com>
         <CAAeHK+zx6W_yxnoEQ2Pc1AT4uLXqYZaoi5oQBeuCntdGS38TQg@mail.gmail.com>
         <580392d8-fa33-67bb-c5d6-27d262f1646a@cumulusnetworks.com>
         <CAAeHK+zZb=K4X9=NmSWQJL8bpgMbXoG+h4RasAyYDr+C5pkVYA@mail.gmail.com>
         <CAM_iQpXyDN5GD+QLmWgJSc0bqV0ViK5LxSdwAV3XsHWr6vLJ2Q@mail.gmail.com>
         <1dad955e-28c1-3f02-8876-90cce4a7d1f8@cumulusnetworks.com>
         <CACT4Y+amFHj1DV3pmj+eJVxg52+GLdE-fEin5M86dOKubea7DQ@mail.gmail.com>
         <CAAeHK+zWO1COcZDp9q4eHP9YN9Qv8CXLOJu8dJgCbihcFSK3jg@mail.gmail.com>
         <CAAeHK+zSe82vc5gCRgr_EoUwiALPnWVdWJBPwJZBpbxYz=kGJw@mail.gmail.com>
         <623b6343-14f4-945d-a1bd-c9971b9566c2@cumulusnetworks.com>
         <CAAeHK+yzCYZ+OU+eTpNLy-_X=7HSNUDML6jcVBKK9sxJ2ByORg@mail.gmail.com>
         <CAAeHK+xUnYqzPOs3jnUn=89Ey_sUZCspW8=--_tP1x=sE=K23w@mail.gmail.com>
         <e64e9ae6-5de9-1fc8-6a79-1724ef03c252@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrey Konovalov <andreyknvl@google.com>,
        Dmitry Vyukov <dvyukov@google.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        syzkaller <syzkaller@googlegroups.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33315 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162213AbdDUSsk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 14:48:40 -0400
In-Reply-To: <e64e9ae6-5de9-1fc8-6a79-1724ef03c252@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-04-21 at 08:27 -0600, David Ahern wrote:
> On 4/20/17 10:09 AM, Andrey Konovalov wrote:
> > On Thu, Apr 20, 2017 at 5:39 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
> >> On Thu, Apr 20, 2017 at 5:35 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> >>> On 4/20/17 9:28 AM, Andrey Konovalov wrote:
> >>>> This one seems to be much closer to what Dmitry reported intially.
> >>> does not repro here; I ran in a loop and nothing.
> > Here's strace log, maybe it'll help figuring out why it doesn't reproduce:
> 
> reproduced. working on it.

Thanks guys for working on this ;)
