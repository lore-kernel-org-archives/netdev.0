From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] tools: bpftool: try to mount bpffs if required
 for pinning objects
Date: Wed, 25 Oct 2017 18:44:07 -0700
Message-ID: <20171026014406.g5h5qda3mzzdczq4@ast-mbp>
References: <20171025031128.13990-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net, Quentin Monnet <quentin.monnet@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:43042 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdJZBoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:44:13 -0400
Received: by mail-pg0-f65.google.com with SMTP id s75so1441363pgs.0
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 18:44:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171025031128.13990-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 24, 2017 at 08:11:28PM -0700, Jakub Kicinski wrote:
> From: Quentin Monnet <quentin.monnet@netronome.com>
> 
> One possible cause of failure for `bpftool {prog|map} pin * file FILE`
> is the FILE not being in an eBPF virtual file system (bpffs). In this
> case, make bpftool attempt to mount bpffs on the parent directory of the
> FILE. Then, if this operation is successful, try again to pin the
> object.
> 
> The code for mnt_bpffs() is a copy of function bpf_mnt_fs() from
> iproute2 package (under lib/bpf.c, taken at commit 4b73d52f8a81), with
> modifications regarding handling of error messages.
> 
> Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

the choice of mounting in the dir where the file is feels a bit
too simplistic, but I don't have better ideas and it helps new users, so
Acked-by: Alexei Starovoitov <ast@kernel.org>
