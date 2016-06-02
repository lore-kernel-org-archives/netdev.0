From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [RFC 02/12] net: cls_bpf: add hardware offload
Date: Thu, 2 Jun 2016 13:07:12 +0100
Message-ID: <20160602130712.54b9575e@jkicinski-Precision-T1700>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
	<1464799814-4453-3-git-send-email-jakub.kicinski@netronome.com>
	<20160602071715.GB1987@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:38503 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbcFBMHR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2016 08:07:17 -0400
Received: by mail-wm0-f51.google.com with SMTP id a20so64535124wma.1
        for <netdev@vger.kernel.org>; Thu, 02 Jun 2016 05:07:16 -0700 (PDT)
In-Reply-To: <20160602071715.GB1987@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2 Jun 2016 09:17:15 +0200, Jiri Pirko wrote:
> >+static void cls_bpf_stop_offload(struct tcf_proto *tp,
> >+				 struct cls_bpf_prog *prog)
> >+{
> >+	struct net_device *dev = tp->q->dev_queue->dev;
> >+
> >+	if (!prog->offloaded)
> >+		return;
> >+	if (WARN_ON(!tc_should_offload(dev, 0)))
> >+		return;
> >+
> >+	if (cls_bpf_offload_cmd(tp, prog, TC_CLSBPF_DESTROY)) {  
> 
> Please do:
> err = 
> if (err)

Sure!
