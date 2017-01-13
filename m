From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] Add support for rt_protos.d
Date: Thu, 12 Jan 2017 17:27:06 -0800
Message-ID: <20170112172706.4832fb67@xeon-e3>
References: <1484005389-29381-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35147 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750779AbdAMB1O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 20:27:14 -0500
Received: by mail-pf0-f181.google.com with SMTP id f144so21777943pfa.2
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 17:27:14 -0800 (PST)
In-Reply-To: <1484005389-29381-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  9 Jan 2017 15:43:09 -0800
David Ahern <dsa@cumulusnetworks.com> wrote:

> Add support for reading proto id/name mappings from rt_protos.d
> directory. Allows users to have custom protocol values converted
> to human friendly names.
> 
> Each file under rt_protos.d has the 'id name' format used by
> rt_protos. Only .conf files are read and parsed.
> 
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
>  etc/iproute2/rt_protos.d/README |  3 +++
>  lib/rt_names.c                  | 27 +++++++++++++++++++++++++++
>  2 files changed, 30 insertions(+)
>  create mode 100644 etc/iproute2/rt_protos.d/README
> 
> diff --git a/etc/iproute2/rt_protos.d/README b/etc/iproute2/rt_protos.d/README
> new file mode 100644
> index 000000000000..723509ce56b6
> --- /dev/null
> +++ b/etc/iproute2/rt_protos.d/README
> @@ -0,0 +1,3 @@
> +Each file in this directory is an rt_protos configuration file. iproute2
> +commands scan this directory processing all files that end in '.conf'.
> +

Applied, but required manual fixup.


.git/rebase-apply/patch:15: new blank line at EOF.
+
warning: 1 line adds whitespace errors.
