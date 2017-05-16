From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] [PATCH net-next 9/9] nfp: eliminate an if
 statement in calculation of completed frames
Date: Tue, 16 May 2017 08:57:01 +0200
Message-ID: <20170516065659.GB11965@vergenet.net>
References: <20170516005523.26124-1-jakub.kicinski@netronome.com>
 <20170516005523.26124-10-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:36759 "EHLO
        mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750795AbdEPG5D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 16 May 2017 02:57:03 -0400
Received: by mail-qk0-f172.google.com with SMTP id u75so118430190qka.3
        for <netdev@vger.kernel.org>; Mon, 15 May 2017 23:57:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170516005523.26124-10-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 15, 2017 at 05:55:23PM -0700, Jakub Kicinski wrote:
> Given that our rings are always a power of 2, we can simplify the
> calculation of number of completed TX descriptors by using masking
> instead of if statement based on whether the index have wrapped
> or not.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
