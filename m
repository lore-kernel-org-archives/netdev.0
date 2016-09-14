From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCHv3 net-next 04/15] bpf: don't (ab)use instructions to
 store state
Date: Wed, 14 Sep 2016 15:58:06 -0700
Message-ID: <20160914225804.GA60248@ast-mbp.thefacebook.com>
References: <1473879623-15382-1-git-send-email-jakub.kicinski@netronome.com>
 <1473879623-15382-5-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
        jiri@resnulli.us, john.fastabend@gmail.com, kubakici@wp.pl
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36090 "EHLO
        mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755204AbcINW6f (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 18:58:35 -0400
Received: by mail-pa0-f46.google.com with SMTP id id6so9538519pad.3
        for <netdev@vger.kernel.org>; Wed, 14 Sep 2016 15:58:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1473879623-15382-5-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2016 at 08:00:12PM +0100, Jakub Kicinski wrote:
> Storing state in reserved fields of instructions makes
> it impossible to run validator on programs already
> marked as read-only. Allocate and use an array of
> per-instruction state instead.
> 
> While touching the error path rename and move existing
> jump target.
> 
> Suggested-by: Alexei Starovoitov <ast@kernel.org>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Nice and clean. Thanks!
Acked-by: Alexei Starovoitov <ast@kernel.org>
