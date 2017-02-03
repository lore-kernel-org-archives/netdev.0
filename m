From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/2] net: core: Two Helper function about socket
 information
Date: Thu, 2 Feb 2017 16:13:31 -0800
Message-ID: <20170203001329.GB42563@ast-mbp.thefacebook.com>
References: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
        Alexei Starovoitov <ast@fb.com>, netdev@vger.kernel.org,
        Willem de Bruijn <willemb@google.com>,
        Lorenzo Colitti <lorenzo@google.com>
To: Chenbo Feng <chenbofeng.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:34867 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751500AbdBCANf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 19:13:35 -0500
Received: by mail-pg0-f65.google.com with SMTP id 204so331258pge.2
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 16:13:35 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20170202205950.100334-1-chenbofeng.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 02, 2017 at 12:59:48PM -0800, Chenbo Feng wrote:
> Introduce two eBpf helper function to get the socket cookie and
> socket uid for each packet. The helper function is useful when
> the *sk field inside sk_buff is not empty.

Looks nice.
I'd like to see a sample code/test for it though.
I think sk_uid is self explanatory, but cookie is less so.
Please explain how you plan to use it.

Thanks
