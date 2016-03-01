From: Amir Vadai <amir@vadai.me>
Subject: Re: [PATCH net-next 1/8] net/flower: Introduce hardware offload
 support
Date: Tue, 1 Mar 2016 18:49:27 +0200
Message-ID: <56d5c71f.a151c20a.cf0a8.ffffd4ad@mx.google.com>
References: <1456842290-7844-1-git-send-email-amir@vadai.me>
 <1456842290-7844-2-git-send-email-amir@vadai.me>
 <20160301144719.GA2098@nanopsycho.orion>
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
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36337 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750849AbcCAQpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 11:45:22 -0500
Received: by mail-wm0-f65.google.com with SMTP id l68so5058684wml.3
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2016 08:45:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160301144719.GA2098@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 01, 2016 at 03:47:19PM +0100, Jiri Pirko wrote:
> Tue, Mar 01, 2016 at 03:24:43PM CET, amir@vadai.me wrote:
> >This patch is based on a patch made by John Fastabend.
> >It adds support for offloading cls_flower.
> >A filter that is offloaded successfuly by hardware, will not be added to
> >the hashtable and won't be processed by software.
> 
> That is wrong. User should explitly specify to not include rule into sw
> by SKIP_KERNEL flag (does not exist now, with John's recent patch we'll
> have only SKIP_HW). Please add that in this patchset.
Why? If a rule is offloaded, why would the user want to reprocess it by
software?
If the user use SKIP_HW, it will be processed by SW. Else, the user
would want it to be processed by HW or fallback to SW. I don't
understand in which case the user would like to have it done twice.

> 

[..]
