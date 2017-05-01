From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH net-next] samples/bpf: Add support for SKB_MODE to xdp1
 and xdp_tx_iptunnel
Date: Mon, 1 May 2017 11:09:56 +0200
Message-ID: <20170501110956.3e82545a@redhat.com>
References: <1493309473-27384-1-git-send-email-dsa@cumulusnetworks.com>
        <20170428234035.5f0beec6@redhat.com>
        <5607e461-b74f-f8b7-8d47-a5341259ddff@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        brouer@redhat.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52350 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S642825AbdEAJKD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 1 May 2017 05:10:03 -0400
In-Reply-To: <5607e461-b74f-f8b7-8d47-a5341259ddff@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 30 Apr 2017 17:46:13 -0600
David Ahern <dsa@cumulusnetworks.com> wrote:

> On 4/28/17 3:40 PM, Jesper Dangaard Brouer wrote:
> > [...]  
> >> diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
> >> index 0d449d8032d1..d4433a47e6c3 100644
> >> --- a/samples/bpf/bpf_load.c
> >> +++ b/samples/bpf/bpf_load.c
> >> @@ -563,7 +563,7 @@ struct ksym *ksym_search(long key)
> >>  	return &syms[0];
> >>  }
> >>  
> >> -int set_link_xdp_fd(int ifindex, int fd)
> >> +int set_link_xdp_fd(int ifindex, int fd, int flags)  
> > Shouldn't the flags be a unsigned int, actually a __u32 ?
> >   
> 
> sure. I'll send a patch

I found another bug in xdp_tx_iptunnel ... I'll send a patch for both issues.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
