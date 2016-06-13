From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next] net/sched: flower: Return error when hw can't
 offload and skip_sw is set
Date: Mon, 13 Jun 2016 14:26:30 +0200
Message-ID: <20160613122630.GC2037@nanopsycho.orion>
References: <20160613090639.31110-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jakub Kicinski <jakub.kicinski@netronome.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:36649 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964968AbcFMM0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jun 2016 08:26:34 -0400
Received: by mail-wm0-f67.google.com with SMTP id m124so14455210wme.3
        for <netdev@vger.kernel.org>; Mon, 13 Jun 2016 05:26:33 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160613090639.31110-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Jun 13, 2016 at 11:06:39AM CEST, amir@vadai.me wrote:
>From: Amir Vadai <amirva@mellanox.com>
>
>When skip_sw is set and hardware fails to apply filter, return error to
>user. This will make error propagation logic similar to the one
>currently used in u32 classifier.
>Also, changed code to use tc_skip_sw() utility function.
>
>Signed-off-by: Amir Vadai <amirva@mellanox.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
