From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next 1/8] net/flower: Introduce hardware offload
 support
Date: Tue, 1 Mar 2016 15:53:44 +0100
Message-ID: <20160301145344.GC2098@nanopsycho.orion>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-2-git-send-email-amir@vadai.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Amir Vadai <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33140 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754250AbcCAOxr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 09:53:47 -0500
Received: by mail-wm0-f68.google.com with SMTP id n186so4531020wmn.0
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 06:53:47 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1456842290-7844-2-git-send-email-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tue, Mar 01, 2016 at 03:24:43PM CET, amir@vadai.me wrote:
>This patch is based on a patch made by John Fastabend.
>It adds support for offloading cls_flower.
>A filter that is offloaded successfuly by hardware, will not be added to
>the hashtable and won't be processed by software.
>

<snip>

>+enum {
>+	TC_CLSFLOWER_REPLACE,
>+	TC_CLSFLOWER_DESTROY,
>+};

Name this enum

>+
>+struct tc_cls_flower_offload {
>+	int command;

        ^^^ and use it here

>+	u64 cookie;
>+	struct flow_dissector *dissector;
>+	struct fl_flow_key *mask;
>+	struct fl_flow_key *key;
>+	struct tcf_exts *exts;
>+};
