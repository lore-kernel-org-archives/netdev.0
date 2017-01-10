From: "Andrey Jr. Melnikov" <temnota.am@gmail.com>
Subject: Re: [PATCH net-next] net: ipv6: put autoconf routes into per-interface tables
Date: Tue, 10 Jan 2017 16:21:36 +0300
Message-ID: <un3fkd-lod.ln1@banana.localnet>
References: <20170106153026.24785-1-lorenzo@google.com> <37df3b18-d17b-5875-7b44-db40be7b459c@cumulusnetworks.com> <CAKD1Yr2U2Oh5yvHE7Znfc9mHzM4K6B_kU82Qctpcsmnt3y5GdQ@mail.gmail.com> <e282793e-4057-7fe6-8322-e1899d873ae2@cumulusnetworks.com> <CAKD1Yr21W2Ce6mhAqfz+mFUPTn+xn3K_Lz2q5LA27f6V=9tTSQ@mail.gmail.com> <161222cb-5c61-d016-bc0f-2453fb0408b7@cumulusnetworks.com> <CAKD1Yr0BnYNTYtCBHLy=KuhX3_23p8eQst61CoC0BHEr5PVkjQ@mail.gmail.com> <bbcab8bb-6a2a-6b90-f6a2-ad840a2c389c@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.159.176.226] ([195.159.176.226]:41860 "EHLO
        blaine.gmane.org" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
        with ESMTP id S932177AbdAJNdm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 08:33:42 -0500
Received: from list by blaine.gmane.org with local (Exim 4.84_2)
        (envelope-from <linux-netdev-2@m.gmane.org>)
        id 1cQwY5-0006Gl-VO
        for netdev@vger.kernel.org; Tue, 10 Jan 2017 14:33:13 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsa@cumulusnetworks.com> wrote:
> On 1/9/17 8:30 PM, Lorenzo Colitti wrote:
> > On Tue, Jan 10, 2017 at 12:04 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> >>> I have no firsthand experience of this myself, but if the problems
> >>> that Andrey reports above in this thread are real, then those would
> >>> indicate that the code is not well-supported. Being unable to accept
> >>> DAD is a pretty serious issue. Andrey, what version of the kernel did
> >>> you see this on?
> >>
> >> Are you referencing an Android or google thread? This patch thread has not mentioned any IPv6 problems.
> > 
> > No, this thread. I see message-ID 8cddkd-etc.ln1@banana.localnet in
> > this thread. If you didn't get it, I also see it in the comments on
> > patchwork - https://patchwork.ozlabs.org/patch/711956/
> > 

> Odd that I did not get that -- checked spam and trash.

> Andrey is missing 830218c1add1da16519b71909e5cf21522b7d062 which tells me the comment is not based on 4.10 or net-next:

> $ git describe 830218c1add1da16519b71909e5cf21522b7d062
> v4.8-14744-g830218c1add1

Good catch. I'm running 4.8 without this patch. Current 4.10-rc works. Sorry
for noise.
