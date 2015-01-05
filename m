From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [PATCH] net: flow: Allow actions and matches to be NULL in
 net_flow_put_flow()
Date: Mon, 5 Jan 2015 11:06:18 +0900
Message-ID: <20150105020616.GB15716@vergenet.net>
References: <1419819602-23290-1-git-send-email-simon.horman@netronome.com>
 <54A195C7.3010009@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:56117 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752937AbbAECG2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2015 21:06:28 -0500
Received: by mail-pd0-f179.google.com with SMTP id fp1so27192638pdb.38
        for <netdev@vger.kernel.org>; Sun, 04 Jan 2015 18:06:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <54A195C7.3010009@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 29, 2014 at 09:56:23AM -0800, John Fastabend wrote:
> On 12/28/2014 06:20 PM, Simon Horman wrote:
> >This makes the handing of the absence of actions or matches
> >symmetric with net_flow_get_flow().
> >
> >Signed-off-by: Simon Horman <simon.horman@netronome.com>
> >---
> 
> Again thanks I actually just hit this with my rocker implementation
> so very timely fix. Same story here I'll roll it into the patch and
> submit it later today.

Thanks. I have hit a few more minor problems which I have fixes for.
What is the best way to handle them? Rebase them on v1 of your patchset
and post them for review if they are still relevant?
