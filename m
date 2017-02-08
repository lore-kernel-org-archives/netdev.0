From: Joe Stringer <joe@ovn.org>
Subject: Re: [PATCH v2 net-next 5/9] openvswitch: Refactor labels initialization.
Date: Wed, 8 Feb 2017 15:06:46 -0800
Message-ID: <CAPWQB7Gy_pd0ieXqSHXR=W-o0baX30G6yr9BbFLgEVxnP88Qjg@mail.gmail.com>
References: <1486582330-31152-1-git-send-email-jarno@ovn.org> <1486582330-31152-6-git-send-email-jarno@ovn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Jarno Rajahalme <jarno@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slow1-d.mail.gandi.net ([217.70.178.86]:43515 "EHLO
        slow1-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751186AbdBIAhS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 19:37:18 -0500
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net [217.70.183.197])
        by slow1-d.mail.gandi.net (Postfix) with ESMTP id 05FE1535EC6
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:08:10 +0100 (CET)
Received: from mfilter12-d.gandi.net (mfilter12-d.gandi.net [217.70.178.129])
        by relay5-d.mail.gandi.net (Postfix) with ESMTP id AF90741C07E
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:07:09 +0100 (CET)
Received: from relay5-d.mail.gandi.net ([217.70.183.197])
        by mfilter12-d.gandi.net (mfilter12-d.gandi.net [10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id wp2FJxIh6cYD for <netdev@vger.kernel.org>;
        Thu,  9 Feb 2017 00:07:08 +0100 (CET)
Received: from mail-qt0-f169.google.com (mail-qt0-f169.google.com [209.85.216.169])
        (Authenticated sender: joe@ovn.org)
        by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id 1EF3641C088
        for <netdev@vger.kernel.org>; Thu,  9 Feb 2017 00:07:07 +0100 (CET)
Received: by mail-qt0-f169.google.com with SMTP id v23so180992061qtb.0
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:07:07 -0800 (PST)
In-Reply-To: <1486582330-31152-6-git-send-email-jarno@ovn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8 February 2017 at 11:32, Jarno Rajahalme <jarno@ovn.org> wrote:
> Refactoring conntrack labels initialization makes chenges in later

*changes

> patches easier to review.
>
> Signed-off-by: Jarno Rajahalme <jarno@ovn.org>

Minor other nit:

>
>         cl = nf_ct_labels_find(ct);
>         if (!cl) {
>                 nf_ct_labels_ext_add(ct);
>                 cl = nf_ct_labels_find(ct);
>         }
> +
> +       return cl;
> +}
> +
> +/* Initialize labels for a new, to be committed conntrack entry.  Note that

Maybe insert 'yet':

Initialize labels for a new, yet to be committed conntrack entry.  Note that
