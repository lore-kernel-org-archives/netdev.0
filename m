From: Amir Vadai <amir@vadai.me>
Subject: Re: [RFC net-next 6/9] net/cls_flower: Introduce hardware offloading
Date: Mon, 1 Feb 2016 12:43:08 +0200
Message-ID: <56af360f.034cc20a.78f42.3c3c@mx.google.com>
References: <1454315685-32202-1-git-send-email-amir@vadai.me>
 <1454315685-32202-7-git-send-email-amir@vadai.me>
 <56AF25E5.6000105@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36031 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838AbcBAKkS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 05:40:18 -0500
Received: by mail-wm0-f41.google.com with SMTP id p63so63360306wmp.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 02:40:17 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <56AF25E5.6000105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 01, 2016 at 01:31:17AM -0800, John Fastabend wrote:
> On 16-02-01 12:34 AM, Amir Vadai wrote:
> > During initialization, tcf_exts_offload_init() is called to initialize
> > the list of actions description. later on, the classifier description
> > is prepared and sent to the switchdev using switchdev_port_flow_add().
> > 
> > When offloaded, fl_classify() is a NOP - already done in hardware.
> > 
> > Signed-off-by: Amir Vadai <amir@vadai.me>
> > ---
> 
> You need to account for where the classifier is being loaded
> by passing the handle as I did in my patch set. Otherwise you may
> be offloading on egress/ingress or even some qdisc multiple layers
> down in the hierarchy.
Right. Will fix it.

> 
> .John
> 
