From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 2/3] net: cls_u32: move TC offload feature
 bit into cls_u32 offload logic
Date: Fri, 26 Feb 2016 16:56:08 +0100
Message-ID: <20160226155608.GE2158@nanopsycho.orion>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
 <20160226155413.5338.47761.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, simon.horman@netronome.com,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33540 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459AbcBZP4M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 10:56:12 -0500
Received: by mail-wm0-f66.google.com with SMTP id c200so9769761wme.0
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:56:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160226155413.5338.47761.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 26, 2016 at 04:54:13PM CET, john.fastabend@gmail.com wrote:
>In the original series drivers would get offload requests for cls_u32
>rules even if the feature bit is disabled. This meant the driver had
>to do a boiler plate check on the feature bit before adding/deleting
>the rule.
>
>This patch lifts the check into the core code and removes it from the
>driver specific case.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
