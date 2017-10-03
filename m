From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 3/3] tools: bpftool: add documentation
Date: Mon, 2 Oct 2017 21:29:08 -0700
Message-ID: <20171003042906.24mnbsfbs3bkp2wy@ast-mbp>
References: <20171002231130.12406-1-jakub.kicinski@netronome.com>
 <20171002231130.12406-4-jakub.kicinski@netronome.com>
 <20171003005500.yh2gbnofm5ckn54x@ast-mbp>
 <20171002183509.76b2cc65@cakuba>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        oss-drivers@netronome.com,
        David Beckett <david.beckett@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:52762 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750735AbdJCE3M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 00:29:12 -0400
Received: by mail-pf0-f173.google.com with SMTP id a1so751407pfj.9
        for <netdev@vger.kernel.org>; Mon, 02 Oct 2017 21:29:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171002183509.76b2cc65@cakuba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 02, 2017 at 06:35:09PM -0700, Jakub Kicinski wrote:
> > will pretty print them as verifier output as well?
> 
> We tried to use LLVM as a library for this but the interface is
> painfully unstable and it's a heavy dependency.  The current thinking
> is to try to put the instruction printing code in some higher level
> library, but I would rather leave that as a follow up.

follow up, of course.
Not depending on llvm is must have for this tool.
I think we need tiny and simple tools first.
Since you're using gpl+bsd license for this tool I think
it would be fine to copy-paste verifier's pretty print code into it.
