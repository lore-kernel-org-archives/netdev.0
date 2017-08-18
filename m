From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 2/2] xdp: adjust xdp redirect tracepoint to include
 return error code
Date: Fri, 18 Aug 2017 14:29:46 +0200
Message-ID: <20170818142946.1bad7203@redhat.com>
References: <150298692691.6608.11908184719252996949.stgit@firesoul>
        <150298695758.6608.7128764985631537683.stgit@firesoul>
        <5995E472.70609@gmail.com>
        <20170817212857.1de3f557@redhat.com>
        <5995F1D6.8040103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, brouer@redhat.com
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33536 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751644AbdHRM3v (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 18 Aug 2017 08:29:51 -0400
In-Reply-To: <5995F1D6.8040103@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 17 Aug 2017 12:43:18 -0700
John Fastabend <john.fastabend@gmail.com> wrote:

> >>> @@ -2532,12 +2535,14 @@ int xdp_do_redirect(struct net_device *dev, struct xdp_buff *xdp,
> >>>  	ri->map = NULL;
> >>>  	if (unlikely(!fwd)) {
> >>>  		bpf_warn_invalid_xdp_redirect(index);  
> 
> I think we should drop the warn_invalid now that we have a tracepoint.
> The tracepoint is much nicer for debugging vs a warning for what might
> be a valid case depending on xdp program.

I agree.  I'll do that in a follow up patch. I'll likely remove the
bpf_warn_invalid_xdp_redirect() function completely.

We also have bpf_warn_invalid_xdp_action() but that might be relevant
to keep around(?).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
