From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net PATCH v4 0/6] virtio_net XDP fixes and adjust_header support
Date: Mon, 16 Jan 2017 13:51:31 +0800
Message-ID: <23bd0c6b-d612-c5b3-ada4-5682a54d795a@redhat.com>
References: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: John Fastabend <john.fastabend@gmail.com>, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53712 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750764AbdAPFvj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 16 Jan 2017 00:51:39 -0500
In-Reply-To: <20170115235528.28980.85142.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017年01月16日 07:59, John Fastabend wrote:
> This has a fix to handle small buffer free logic correctly and then
> also adds adjust head support.
>
> I pushed adjust head at net (even though its rc3) to avoid having
> to push another exception case into virtio_net to catch if the
> program uses adjust_head and then block it. If there are any strong
> objections to this we can push it at net-next and use a patch from
> Jakub to add the exception handling but then user space has to deal
> with it either via try/fail logic or via kernel version checks. Granted
> we already have some cases that need to be configured to enable XDP
> but I don't see any reason to have yet another one when we can fix it
> now vs delaying a kernel version.
>
>
> v2: fix spelling error, convert unsigned -> unsigned int
> v3: v2 git crashed during send so retrying sorry for the noise
> v4: changed layout of rtnl_lock fixes (Stephen)
>      moved reset logic into virtio core with new patch (MST)
>      fixed up linearize and some code cleanup (Jason)
>
>      Otherwise did some generic code cleanup so might be a bit
>      cleaner this time at least that is the hope.
>
> Thanks everyone for the v3 review.

Thanks, looks good to me overall, just few nits.
