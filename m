From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH net] net: ipv6: RTF_PCPU should not be settable from
 userspace
Date: Thu, 20 Apr 2017 16:38:13 -0700
Message-ID: <20170420233813.zeoi6eq3lifcnefs@kafai-mba.dhcp.thefacebook.com>
References: <1492636783-29756-1-git-send-email-dsa@cumulusnetworks.com>
 <CAM_iQpUbuzie86Cf96Q9F53UiamJixr-aVkAKtgvZFtiKPngUw@mail.gmail.com>
 <c6f4f382-26ac-6679-adba-605e8f29cf6a@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41036 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S948023AbdDTXiT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 19:38:19 -0400
Content-Disposition: inline
In-Reply-To: <c6f4f382-26ac-6679-adba-605e8f29cf6a@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 20, 2017 at 04:43:03PM -0600, David Ahern wrote:
> On 4/20/17 4:39 PM, Cong Wang wrote:
> > On Wed, Apr 19, 2017 at 2:19 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> >>
> >> Fix by checking for the flag and failing with EINVAL.
> >>
> >
> > I am still not sure about this. There are a few unused bits in
> > this flag, we simply ignore the rest, right? Why should we
> > reject this one instead of all of those we don't use?
> >
>
> RTF_PCPU most definitely should not be set by userspace.
+1
