From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next] net: bpf: fix compiler warnings in test_bpf
Date: Fri, 19 Sep 2014 22:56:05 +0200
Message-ID: <541C9865.6000407@redhat.com>
References: <1411160031-3538-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Fengguang Wu <fengguang.wu@intel.com>, netdev@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20799 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757700AbaISU4L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 16:56:11 -0400
In-Reply-To: <1411160031-3538-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 10:53 PM, Alexei Starovoitov wrote:
> old gcc 4.2 used by avr32 architecture produces warnings:
>
> lib/test_bpf.c:1741: warning: integer constant is too large for 'long' type
> lib/test_bpf.c:1741: warning: integer constant is too large for 'long' type
> lib/test_bpf.c: In function '__run_one':
> lib/test_bpf.c:1897: warning: 'ret' may be used uninitialized in this function
>
> silence these warnings.
>
> Fixes: 02ab695bb37e ("net: filter: add "load 64-bit immediate" eBPF instruction")
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Daniel Borkmann <dborkman@redhat.com>
