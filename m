From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v3 1/3] net: sched: consolidate offload decision
 in cls_u32
Date: Fri, 26 Feb 2016 16:55:49 +0100
Message-ID: <20160226155549.GD2158@nanopsycho.orion>
References: <20160226154858.5338.90569.stgit@john-Precision-Tower-5810>
 <20160226155349.5338.74615.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: daniel@iogearbox.net, simon.horman@netronome.com,
	netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34879 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753896AbcBZPzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Feb 2016 10:55:52 -0500
Received: by mail-wm0-f66.google.com with SMTP id g62so9766124wme.2
        for <netdev@vger.kernel.org>; Fri, 26 Feb 2016 07:55:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160226155349.5338.74615.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Feb 26, 2016 at 04:53:49PM CET, john.fastabend@gmail.com wrote:
>The offload decision was originally very basic and tied to if the dev
>implemented the appropriate ndo op hook. The next step is to allow
>the user to more flexibly define if any paticular rule should be
>offloaded or not. In order to have this logic in one function lift
>the current check into a helper routine tc_should_offload().
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
