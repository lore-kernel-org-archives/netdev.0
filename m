From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/1] bpf: take advantage of stack_depth tracking in powerpc
 JIT
Date: Fri, 01 Sep 2017 21:15:33 +0200
Message-ID: <59A9B1D5.7030307@iogearbox.net>
References: <20170901185301.17978-1-sandipan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: naveen.n.rao@linux.vnet.ibm.com, ast@fb.com,
        netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org
To: Sandipan Das <sandipan@linux.vnet.ibm.com>, mpe@ellerman.id.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40880 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751715AbdIATPl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 15:15:41 -0400
In-Reply-To: <20170901185301.17978-1-sandipan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/01/2017 08:53 PM, Sandipan Das wrote:
> Take advantage of stack_depth tracking, originally introduced for
> x64, in powerpc JIT as well. Round up allocated stack by 16 bytes
> to make sure it stays aligned for functions called from JITed bpf
> program.
>
> Signed-off-by: Sandipan Das <sandipan@linux.vnet.ibm.com>

Awesome, thanks for following up! :)
