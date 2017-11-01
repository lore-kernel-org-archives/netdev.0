From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next] security: bpf: replace include of linux/bpf.h
 with forward declarations
Date: Wed, 1 Nov 2017 11:50:23 -0700
Message-ID: <20171101185021.aw7wiahhj72c7o6u@ast-mbp>
References: <20171101184800.16416-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        daniel@iogearbox.net, Chenbo Feng <fengc@google.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:53591 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932685AbdKASu0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 14:50:26 -0400
Received: by mail-pg0-f68.google.com with SMTP id s2so2843925pge.10
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 11:50:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20171101184800.16416-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 01, 2017 at 11:48:00AM -0700, Jakub Kicinski wrote:
> Touching linux/bpf.h makes us rebuild a surprisingly large
> portion of the kernel.  Remove the unnecessary dependency
> from security.h, it only needs forward declarations.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>

Acked-by: Alexei Starovoitov <ast@kernel.org>

thanks for fixing! I noticed larger rebuilds as well.
