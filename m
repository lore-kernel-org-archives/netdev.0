From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH RFC v2 00/12] socket sendmsg MSG_ZEROCOPY
Date: Fri, 24 Feb 2017 15:03:35 -0800
Message-ID: <20170224230333.GA58409@ast-mbp.thefacebook.com>
References: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36202 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751386AbdBXXLs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Feb 2017 18:11:48 -0500
Received: by mail-pg0-f65.google.com with SMTP id z128so4631173pgb.3
        for <netdev@vger.kernel.org>; Fri, 24 Feb 2017 15:11:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170222163901.90834-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 22, 2017 at 11:38:49AM -0500, Willem de Bruijn wrote:
> 
> * Limitations / Known Issues
> 
> - PF_INET6 is not yet supported.

we struggled so far to make it work in our setups which are ipv6 only.
Looking at patches it seems the code should just work.
What particularly is missing ?

Great stuff. Looking forward to net-next reopening :)
