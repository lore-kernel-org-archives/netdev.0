From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] bpf: add test for the verifier equal logic bug
Date: Tue, 29 Nov 2016 10:54:07 -0800
Message-ID: <20161129185359.GC22581@ast-mbp.thefacebook.com>
References: <1480440919-3252-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, ast@kernel.org,
        jannh@google.com, daniel@iogearbox.net, kernel-team@fb.com
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33410 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751148AbcK2SyL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 13:54:11 -0500
Received: by mail-pg0-f66.google.com with SMTP id 3so17162045pgd.0
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 10:54:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1480440919-3252-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 12:35:19PM -0500, Josef Bacik wrote:
> This is a test to verify that
> 
> bpf: fix states equal logic for varlen access
> 
> actually fixed the problem.  The problem was if the register we added to our map
> register was UNKNOWN in both the false and true branches and the only thing that
> changed was the range then we'd incorrectly assume that the true branch was
> valid, which it really wasnt.  This tests this case and properly fails without
> my fix in place and passes with it in place.
> 
> Signed-off-by: Josef Bacik <jbacik@fb.com>

Awesome. thanks for the test!
Acked-by: Alexei Starovoitov <ast@kernel.org>
