From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [RFC 03/12] net: cls_bpf: limit hardware offload by
 software-only flag
Date: Thu, 2 Jun 2016 09:24:20 +0200
Message-ID: <20160602072018.GC1987@nanopsycho>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
 <1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36370 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751916AbcFBHYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 03:24:24 -0400
Received: by mail-wm0-f45.google.com with SMTP id n184so65407735wmn.1
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 00:24:24 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1464799814-4453-4-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Jun 01, 2016 at 06:50:05PM CEST, jakub.kicinski@netronome.com wrote:
>Add cls_bpf support for the TCA_CLS_FLAGS_SKIP_HW flag.
>Unlike U32 and flower cls_bpf already has some netlink
>flags defined.  I chose to create a new attribute to be
>able to use the same flag values as the above.
>
>Unknown flags are ignored and not reported upon dump.
>
>Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
>Reviewed-by: Simon Horman <simon.horman@netronome.com>


Reviewed-by: Jiri Pirko <jiri@mellanox.com>
