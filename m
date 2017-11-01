From: David Miller <davem@davemloft.net>
Subject: Re: [net PATCH] bpf: remove SK_REDIRECT from UAPI
Date: Wed, 01 Nov 2017 11:44:38 +0900 (KST)
Message-ID: <20171101.114438.1055469346374214087.davem@davemloft.net>
References: <20171101021731.10955.49498.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
        netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44204 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932210AbdKACom (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 22:44:42 -0400
In-Reply-To: <20171101021731.10955.49498.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 31 Oct 2017 19:17:31 -0700

> Now that SK_REDIRECT is no longer a valid return code. Remove it
> from the UAPI completely. Then do a namespace remapping internal
> to sockmap so SK_REDIRECT is no longer externally visible.
> 
> Patchs primary change is to do a namechange from SK_REDIRECT to
> __SK_REDIRECT
> 
> Reported-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Applied, thanks.
