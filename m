From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH/RFC net-next 0/4] net/sched:
 cls_flower: avoid false matching of truncated packets
Date: Tue, 2 May 2017 14:04:29 +0200
Message-ID: <20170502120428.GC24820@vergenet.net>
References: <20170428120035.15984-1-simon.horman@netronome.com>
 <422d55da-f861-1bc6-983d-199fc383c113@mojatatu.com>
 <20170428131155.GA30329@vergenet.net>
 <2c14754a-f3f5-cece-2cd7-361948a00c22@mojatatu.com>
 <20170428141414.GA11256@vergenet.net>
 <0e993860-4dfd-3562-5ccb-c5ad24e5f970@mojatatu.com>
 <20170501103645.GC24399@vergenet.net>
 <c88b57d8-81a5-78e5-add6-33941f912d73@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:35404 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750960AbdEBMEe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 08:04:34 -0400
Received: by mail-wm0-f51.google.com with SMTP id w64so110204796wma.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 05:04:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <c88b57d8-81a5-78e5-add6-33941f912d73@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 01, 2017 at 09:35:47PM -0400, Jamal Hadi Salim wrote:
> On 17-05-01 06:36 AM, Simon Horman wrote:
> >On Sun, Apr 30, 2017 at 09:51:30AM -0400, Jamal Hadi Salim wrote:
> >>On 17-04-28 10:14 AM, Simon Horman wrote:
> 
> [..]
> 
> >>minimal some flag should qualify it as "truncated".
> >
> >Would changing TCA_FLOWER_HEADER_PARSE_ERR_ACT to
> >TCA_FLOWER_META_TRUNCATED help?
> >
> 
> I think so - as long as you are able to recognize the truncated
> vs real 0 port/type etc.

That is the intention of the patchset.
I will make the change and repost.
