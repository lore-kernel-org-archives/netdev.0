From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 -master 2/4] tc, bpf: improve verifier logging
Date: Tue, 2 Feb 2016 16:02:12 +1100
Message-ID: <20160202160212.3b006472@samsung9>
References: <cover.1454370543.git.daniel@iogearbox.net>
	<24df553c2a0dd547a66e215c89ae75fd6818c750.1454370543.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33383 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750710AbcBBFCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 00:02:19 -0500
Received: by mail-pf0-f173.google.com with SMTP id w123so3610350pfb.0
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 21:02:19 -0800 (PST)
In-Reply-To: <24df553c2a0dd547a66e215c89ae75fd6818c750.1454370543.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Feb 2016 01:12:27 +0100
Daniel Borkmann <daniel@iogearbox.net> wrote:

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

Does not apply

Applying: tc, bpf: improve verifier logging
error: patch failed: tc/tc_bpf.c:762
error: tc/tc_bpf.c: patch does not apply
Patch failed at 0002 tc, bpf: improve verifier logging
