From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net] geneve: Fix function matching VNI and tunnel ID on
 big-endian
Date: Thu, 19 Oct 2017 14:08:21 +0200
Message-ID: <20171019140821.0aefacb9@beetle>
References: <7fb32cd5779c5c0133754194aa6914fa8689853e.1508412016.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        pravin shelar <pshelar@ovn.org>,
        Girish Moodalbail <girish.moodalbail@oracle.com>,
        Sabrina Dubroca <sd@queasysnail.net>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f194.google.com ([209.85.128.194]:54555 "EHLO
        mail-wr0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbdJSMIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 08:08:24 -0400
Received: by mail-wr0-f194.google.com with SMTP id o44so8064487wrf.11
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 05:08:24 -0700 (PDT)
In-Reply-To: <7fb32cd5779c5c0133754194aa6914fa8689853e.1508412016.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 Oct 2017 13:31:28 +0200
Stefano Brivio <sbrivio@redhat.com> wrote:

> On big-endian machines, functions converting between tunnel ID
> and VNI use the three LSBs of tunnel ID storage to map VNI.
> 
> The comparison function eq_tun_id_and_vni(), on the other hand,
> attempted to map the VNI from the three MSBs. Fix it by using
> the same check implemented on LE, which maps VNI from the three
> LSBs of tunnel ID.
> 
> Fixes: 2e0b26e10352 ("geneve: Optimize geneve device lookup.")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>

Thanks, Stefano.

Reviewed-by: Jakub Sitnicki <jkbs@redhat.com>
