From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 3/5] genetlink: statically initialize families
Date: Mon, 24 Oct 2016 14:55:33 +0200
Message-ID: <1477313733.4085.11.camel@sipsolutions.net>
References: <1477312805-7110-1-git-send-email-johannes@sipsolutions.net>
         <1477312805-7110-4-git-send-email-johannes@sipsolutions.net>
         (sfid-20161024_144032_073312_7524B853)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:51826 "EHLO sipsolutions.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934873AbcJXMzg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Oct 2016 08:55:36 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.2:ECDHE_RSA_AES_256_GCM_SHA384:256)
        (Exim 4.87)
        (envelope-from <johannes@sipsolutions.net>)
        id 1byems-0005EB-6T
        for netdev@vger.kernel.org; Mon, 24 Oct 2016 14:55:34 +0200
In-Reply-To: <1477312805-7110-4-git-send-email-johannes@sipsolutions.net> (sfid-20161024_144032_073312_7524B853)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-10-24 at 14:40 +0200, Johannes Berg wrote:
> From: Johannes Berg <johannes.berg@intel.com>
> 
> Instead of providing macros/inline functions to initialize
> the families, make all users initialize them statically and
> get rid of the macros.
> 
> This reduces the kernel code size by about 1.6k on x86-64
> (with allyesconfig).

Actually, with the new system where it's not const, I could even split
this up and submit per subsystem, i.e. the fourth patch doesn't depend
on it. I thought it would, since I wanted to make it const, but since I
failed it doesn't actually have that dependency.

johannes
