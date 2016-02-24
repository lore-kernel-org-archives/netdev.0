From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH 2/4] net: cls_u32: move TC offload feature bit
 into cls_u32 offload logic
Date: Wed, 24 Feb 2016 15:12:14 +0900
Message-ID: <20160224061211.GC12134@vergenet.net>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
 <20160223190256.5970.25013.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35376 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbcBXGMX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 01:12:23 -0500
Received: by mail-pa0-f51.google.com with SMTP id ho8so6972560pac.2
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 22:12:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223190256.5970.25013.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 11:02:56AM -0800, John Fastabend wrote:
> In the original series drivers would get offload requests for cls_u32
> rules even if the feature bit is disabled. This meant the driver had
> to do a boiler plate check on the feature bit before adding/deleting
> the rule.
> 
> This patch lifts the check into the core code and removes it from the
> driver specific case.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
