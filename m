From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH iproute2 -master 2/4] tc, bpf: improve verifier logging
Date: Mon, 01 Feb 2016 16:51:56 -0800
Message-ID: <56AFFDAC.3060803@gmail.com>
References: <cover.1454370543.git.daniel@iogearbox.net> <24df553c2a0dd547a66e215c89ae75fd6818c750.1454370543.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34453 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751403AbcBBAwK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 19:52:10 -0500
Received: by mail-pf0-f193.google.com with SMTP id 65so8166580pfd.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 16:52:10 -0800 (PST)
In-Reply-To: <24df553c2a0dd547a66e215c89ae75fd6818c750.1454370543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-01 04:12 PM, Daniel Borkmann wrote:
> With a bit larger, branchy eBPF programs f.e. already ~BPF_MAXINSNS/7 in
> size, it happens rather quickly that bpf(2) rejects also valid programs
> when only the verifier log buffer size we have in tc is too small.
> 
> Change that, so by default we don't do any logging, and only in error
> case we retry with logging enabled. If we should fail providing a
> reasonable dump of the verifier analysis, retry few times with a larger
> log buffer so that we can at least give the user a chance to debug the
> program.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> ---
>  tc/tc_bpf.c | 156 ++++++++++++++++++++++++++++++++++++++++++------------------

Acked-by: John Fastabend <john.r.fastabend@intel.com>


Thanks! I've been hacking around this for a while now but never
got around to fixing it.
