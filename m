From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [net-next PATCH 1/4] net: sched: consolidate offload decision in
 cls_u32
Date: Wed, 24 Feb 2016 15:12:44 +0900
Message-ID: <20160224061242.GD12134@vergenet.net>
References: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jiri@resnulli.us, daniel@iogearbox.net, netdev@vger.kernel.org,
	alexei.starovoitov@gmail.com, davem@davemloft.net, jhs@mojatatu.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:36054 "EHLO
	mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750883AbcBXGMx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 01:12:53 -0500
Received: by mail-pf0-f173.google.com with SMTP id e127so6899940pfe.3
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 22:12:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223190233.5970.61226.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 11:02:33AM -0800, John Fastabend wrote:
> The offload decision was originally very basic and tied to if the dev
> implemented the appropriate ndo op hook. The next step is to allow
> the user to more flexibly define if any paticular rule should be
> offloaded or not. In order to have this logic in one function lift
> the current check into a helper routine tc_should_offload().
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Reviewed-by: Simon Horman <simon.horman@netronome.com>
