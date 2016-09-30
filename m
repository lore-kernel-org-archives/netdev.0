From: pravin shelar <pshelar@ovn.org>
Subject: Re: [PATCH net-next v2 2/3] mpls: move mpls_hdr to a common location
Date: Fri, 30 Sep 2016 10:43:42 -0700
Message-ID: <CAOrHB_BJqka5HGpeJ1GF42X2kQOmzrLY_LQt4Td6zrAX84Fjow@mail.gmail.com>
References: <cover.1475255100.git.jbenc@redhat.com> <4556158d9b279156a5c41054f1e803c004bc28e9.1475255100.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:41512 "EHLO
        relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932887AbcI3Rnt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 13:43:49 -0400
Received: from mfilter17-d.gandi.net (mfilter17-d.gandi.net [217.70.178.145])
        by relay3-d.mail.gandi.net (Postfix) with ESMTP id A4E3EA80CB
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 19:43:45 +0200 (CEST)
Received: from relay3-d.mail.gandi.net ([IPv6:::ffff:217.70.183.195])
        by mfilter17-d.gandi.net (mfilter17-d.gandi.net [::ffff:10.0.15.180]) (amavisd-new, port 10024)
        with ESMTP id LmEx_mbzIsE2 for <netdev@vger.kernel.org>;
        Fri, 30 Sep 2016 19:43:44 +0200 (CEST)
Received: from mail-it0-f46.google.com (mail-it0-f46.google.com [209.85.214.46])
        (Authenticated sender: pshelar@ovn.org)
        by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 242FCA80C7
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 19:43:44 +0200 (CEST)
Received: by mail-it0-f46.google.com with SMTP id u134so56856700itb.1
        for <netdev@vger.kernel.org>; Fri, 30 Sep 2016 10:43:43 -0700 (PDT)
In-Reply-To: <4556158d9b279156a5c41054f1e803c004bc28e9.1475255100.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 30, 2016 at 10:08 AM, Jiri Benc <jbenc@redhat.com> wrote:
> This will be also used by openvswitch.
>
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> ---
> v2: new in v2
> ---
>  include/net/mpls.h  |  9 +++++++++
>  net/mpls/internal.h | 10 +---------
>  2 files changed, 10 insertions(+), 9 deletions(-)
>
> diff --git a/include/net/mpls.h b/include/net/mpls.h
> index 5b3b5addfb08..3ebbc0bb57ff 100644
> --- a/include/net/mpls.h
> +++ b/include/net/mpls.h
> @@ -19,12 +19,21 @@
>
>  #define MPLS_HLEN 4
>
> +struct mpls_shim_hdr {
> +       __be32 label_stack_entry;
> +};
> +
There is already struct mpls_label defined in uapi mpls header file.
Is there reason for not using it here?
