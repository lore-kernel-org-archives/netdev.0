From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH net-next] vxlan: remove vni zero check and drop for COLLECT_METADATA
Date: Sat, 11 Feb 2017 12:09:22 -0800
Message-ID: <CAPWQB7FU8UxAOy+Cw0vjN9giTjNNMHr1hLDgtyUgVBwEY+_+3Q@mail.gmail.com>
References: <1486791516-10285-1-git-send-email-roopa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>
To: Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay6-d.mail.gandi.net ([217.70.183.198]:36353 "EHLO
        relay6-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751027AbdBKUJs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 11 Feb 2017 15:09:48 -0500
Received: from mfilter20-d.gandi.net (mfilter20-d.gandi.net [217.70.178.148])
        by relay6-d.mail.gandi.net (Postfix) with ESMTP id 5C8D1FB881
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 21:09:45 +0100 (CET)
Received: from relay6-d.mail.gandi.net ([IPv6:::ffff:217.70.183.198])
        by mfilter20-d.gandi.net (mfilter20-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id Sc3raoCmsZbx for <netdev@vger.kernel.org>;
        Sat, 11 Feb 2017 21:09:43 +0100 (CET)
Received: from mail-qt0-f174.google.com (mail-qt0-f174.google.com [209.85.216.174])
        (Authenticated sender: joe@ovn.org)
        by relay6-d.mail.gandi.net (Postfix) with ESMTPSA id 82863FB877
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 21:09:43 +0100 (CET)
Received: by mail-qt0-f174.google.com with SMTP id v23so60120192qtb.0
        for <netdev@vger.kernel.org>; Sat, 11 Feb 2017 12:09:43 -0800 (PST)
In-Reply-To: <1486791516-10285-1-git-send-email-roopa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10 February 2017 at 21:38, Roopa Prabhu <roopa@cumulusnetworks.com> wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
>
> This patch drops the vni zero check for COLLECT_METADATA mode.
> It is not really needed, vni zero is a valid vni.
>
> Fixes: 3ad7a4b141eb ("vxlan: support fdb and learning in COLLECT_METADATA mode"
> Reported-by: Joe Stringer <joe@ovn.org>
> Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Thanks, I tried this out and it fixes the issue.
