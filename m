From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH v4 net-next RFC] net: Generic XDP
Date: Sat, 15 Apr 2017 09:46:43 -0600
Message-ID: <b4a5244e-306d-a5cc-2ad7-1907c80a1601@cumulusnetworks.com>
References: <20170413.120925.2082322246776478766.davem@davemloft.net>
 <CACKFLikm1vDzz8eQJMJOEsbv-NNV41ki2TEPVPCSpP6VjaowBA@mail.gmail.com>
 <20170413.162315.1889531431093534154.davem@davemloft.net>
 <20170415005949.GB73685@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: michael.chan@broadcom.com, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34650 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753778AbdDOPqs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 15 Apr 2017 11:46:48 -0400
Received: by mail-pg0-f48.google.com with SMTP id t187so2361606pgt.1
        for <netdev@vger.kernel.org>; Sat, 15 Apr 2017 08:46:48 -0700 (PDT)
In-Reply-To: <20170415005949.GB73685@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/14/17 6:59 PM, Alexei Starovoitov wrote:
> I'll test it next week unless people beat me to it.
> 

I have run the xdp1 example from samples/bpf.

I have a patch that modifies set_link_xdp_fd to take a flags argument
which it adds to the request as the IFLA_XDP_FLAGS attribute. That's
used by callers to set XDP_FLAGS_SKB_MODE.
