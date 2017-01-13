From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net PATCH v2 0/5] virtio_net XDP fixes and adjust_header support
Date: Thu, 12 Jan 2017 18:54:14 -0800
Message-ID: <58784156.5040006@gmail.com>
References: <20170113003412.4167.12250.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
        alexei.starovoitov@gmail.com, daniel@iogearbox.net
To: jasowang@redhat.com, mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36497 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750877AbdAMCy2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 21:54:28 -0500
Received: by mail-pf0-f195.google.com with SMTP id b22so6044607pfd.3
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 18:54:27 -0800 (PST)
In-Reply-To: <20170113003412.4167.12250.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-01-12 04:34 PM, John Fastabend wrote:
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
> 
> ---

Sorry about the v2 here I got a connection reset by peer error from
git and it seems only 2/5 patches made it to the list. To avoid as much
confusion as possible I just sent a v3 and it seems to have completed
correctly.

Thanks,
John
