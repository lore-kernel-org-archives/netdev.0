From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next v2] tc: built-in eBPF exec proxy
Date: Tue, 28 Apr 2015 09:45:08 +0200
Message-ID: <553F3A84.40306@iogearbox.net>
References: <d41d6003521cbb231112e4a78c10cb8c07f05cc2.1429211530.git.daniel@iogearbox.net> <20150427164144.2d7279ef@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, ast@plumgrid.com,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44705 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932293AbbD1HpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 03:45:13 -0400
In-Reply-To: <20150427164144.2d7279ef@urahara>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/28/2015 01:41 AM, Stephen Hemminger wrote:
...
> This will go in for 4.1 version of iproute2.

Ok, thanks!

Btw, I noticed that we still need a header rebase for the 'master'
branch.

Due to the merge window, eBPF support for tracing came in as well
meaning currently, the kernel thinks we intend to attach a kprobe
program from tc side:

iproute2 version:

   enum bpf_prog_type {
     BPF_PROG_TYPE_UNSPEC,
     BPF_PROG_TYPE_SOCKET_FILTER,
     BPF_PROG_TYPE_SCHED_CLS,
     BPF_PROG_TYPE_SCHED_ACT,
   };

kernel version (include/uapi/linux/bpf.h):

   enum bpf_prog_type {
     BPF_PROG_TYPE_UNSPEC,
     BPF_PROG_TYPE_SOCKET_FILTER,
     BPF_PROG_TYPE_KPROBE,
     BPF_PROG_TYPE_SCHED_CLS,
     BPF_PROG_TYPE_SCHED_ACT,
   };

Afaik, you have a script for doing that, otherwise I can also send
you a patch.

Thanks,
Daniel
