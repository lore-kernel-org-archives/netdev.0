From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH] bpf: Remove unused but set variables
Date: Tue, 8 Nov 2016 13:45:40 -0800
Message-ID: <20161108214538.GA41350@ast-mbp.thefacebook.com>
References: <20161108154028.13334-1-tklauser@distanz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        Josef Bacik <jbacik@fb.com>
To: Tobias Klauser <tklauser@distanz.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35691 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753831AbcKHVpo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2016 16:45:44 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so20902268pfk.2
        for <netdev@vger.kernel.org>; Tue, 08 Nov 2016 13:45:44 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161108154028.13334-1-tklauser@distanz.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2016 at 04:40:28PM +0100, Tobias Klauser wrote:
> Remove the unused but set variables min_set and max_set in
> adjust_reg_min_max_vals to fix the following warning when building with
> 'W=1':
> 
>   kernel/bpf/verifier.c:1483:7: warning: variable ‘min_set’ set but not used [-Wunused-but-set-variable]
> 
> There is no warning about max_set being unused, but since it is only
> used in the assignment of min_set it can be removed as well.
> 
> They were introduced in commit 484611357c19 ("bpf: allow access into map
> value arrays") but seem to have never been used.
> 
> Cc: Josef Bacik <jbacik@fb.com>
> Signed-off-by: Tobias Klauser <tklauser@distanz.ch>
> ---

Acked-by: Alexei Starovoitov <ast@kernel.org>
