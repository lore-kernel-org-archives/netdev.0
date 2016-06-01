From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC 03/12] net: cls_bpf: limit hardware offload by software-only
 flag
Date: Wed, 1 Jun 2016 10:16:12 -0700
Message-ID: <574F185C.6030704@gmail.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33550 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753789AbcFARQd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 13:16:33 -0400
Received: by mail-pf0-f180.google.com with SMTP id b124so18839312pfb.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 10:16:32 -0700 (PDT)
In-Reply-To: <1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-06-01 09:50 AM, Jakub Kicinski wrote:
> Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_HW flag.
> Unlike U32 and flower cls_bpf already has some netlink
> flags defined.  I chose to create a new attribute to be
> able to use the same flag values as the above.
> 
> Unknown flags are ignored and not reported upon dump.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>
> ---

Seems reasonable to me. Adding support for the SKIP_SW flag
as well would be helpful. It looks like you could do this
fairly easily by checking the offload boolean. Anyways that
is another patch of course.

Acked-by: John Fastabend <john.r.fastabend@intel.com>
