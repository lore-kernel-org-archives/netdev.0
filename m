From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v3 00/11] Improve BPF selftests and use the
 library (net-next tree)
Date: Wed, 08 Feb 2017 14:15:22 -0500 (EST)
Message-ID: <20170208.141522.424956451444145195.davem@davemloft.net>
References: <20170207214500.27496-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: linux-kernel@vger.kernel.org, ast@fb.com, acme@redhat.com,
        daniel@iogearbox.net, netdev@vger.kernel.org
To: mic@digikod.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56952 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752029AbdBHTRt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 14:17:49 -0500
In-Reply-To: <20170207214500.27496-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mickaël Salaün <mic@digikod.net>
Date: Tue,  7 Feb 2017 22:44:49 +0100

> This series brings some fixes to selftests, add the ability to test
> unprivileged BPF programs as root and replace bpf_sys.h with calls to the BPF
> library.
> 
> This is intended for the net-next tree and apply on 76e0e70e6452 ("liquidio: do
> not dereference pointer if it's NULL").
> 
> Changes since v2:
> * use the patches from two previous series (unprivileged tests and bpf_sys.h
>   replacement)
> * include one more stdint.h
> * rebase on net-next
> * add this cover letter
> 
> Changes since v1:
> * exclude patches not intended for the net-next tree

I'm waiting for the feedback to be addressed on patch #4 (bzero vs. variable
initializer) before applying this series.
