From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH v2 2/8] net: rework setup_tc ndo op to consume
 general tc operand
Date: Tue, 16 Feb 2016 21:17:21 +0100
Message-ID: <20160216201721.GB2246@nanopsycho.orion>
References: <20160216055819.32452.84181.stgit@john-Precision-Tower-5810>
 <20160216060057.32452.75845.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, jhs@mojatatu.com, davem@davemloft.net,
	netdev@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35071 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbcBPURY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 15:17:24 -0500
Received: by mail-wm0-f41.google.com with SMTP id c200so180557607wme.0
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 12:17:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160216060057.32452.75845.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Feb 16, 2016 at 07:00:57AM CET, john.fastabend@gmail.com wrote:
>This patch updates setup_tc so we can pass additional parameters into
>the ndo op in a generic way. To do this we provide structured union
>and type flag.
>
>This lets each classifier and qdisc provide its own set of attributes
>without having to add new ndo ops or grow the signature of the
>callback.
>
>Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
