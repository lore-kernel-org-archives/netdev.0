From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 1/8] net/flower: Introduce hardware offload
 support
Date: Tue, 1 Mar 2016 18:50:28 +0200
Message-ID: <56d5c75c.84b61c0a.2e19f.ffff93e1@mx.google.com>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-2-git-send-email-amir@vadai.me>
 <20160301145344.GC2098@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:33969 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbcCAQqW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 11:46:22 -0500
Received: by mail-wm0-f68.google.com with SMTP id p65so5083134wmp.1
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 08:46:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160301145344.GC2098@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2016 at 03:53:44PM +0100, Jiri Pirko wrote:
> Tue, Mar 01, 2016 at 03:24:43PM CET, amir@vadai.me wrote:
> >This patch is based on a patch made by John Fastabend.
> >It adds support for offloading cls_flower.
> >A filter that is offloaded successfuly by hardware, will not be added to
> >the hashtable and won't be processed by software.
> >
> 
> <snip>
> 
> >+enum {
> >+	TC_CLSFLOWER_REPLACE,
> >+	TC_CLSFLOWER_DESTROY,
> >+};
> 
> Name this enum
Right,
Thanks

> 
> >+
> >+struct tc_cls_flower_offload {
> >+	int command;
> 
>         ^^^ and use it here
> 
> >+	u64 cookie;
> >+	struct flow_dissector *dissector;
> >+	struct fl_flow_key *mask;
> >+	struct fl_flow_key *key;
> >+	struct tcf_exts *exts;
> >+};
