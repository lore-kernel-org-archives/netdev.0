From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 0/5] Add bpf support to set sk_bound_dev_if
Date: Mon, 31 Oct 2016 18:46:56 +0100
Message-ID: <20161031174656.GE32374@pox.localdomain>
References: <1477529922-4806-1-git-send-email-dsa@cumulusnetworks.com>
 <20161031.130104.2206412054220058623.davem@davemloft.net>
 <69b9c20b-9566-5f75-cebd-a0bd243c2d65@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        daniel@zonque.org, ast@fb.com, daniel@iogearbox.net,
        maheshb@google.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:38404 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S945135AbcJaRq6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 13:46:58 -0400
Received: by mail-wm0-f54.google.com with SMTP id n67so243201015wme.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 10:46:58 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <69b9c20b-9566-5f75-cebd-a0bd243c2d65@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/31/16 at 11:16am, David Ahern wrote:
> On 10/31/16 11:01 AM, David Miller wrote:
> > Also, any reason why you don't allow the cgroup bpf sk filter to return
> > an error code so that the sock creation could be cancelled if the eBPF
> > program desires that?  It could be useful, I suppose.
> 
> My first draft at this feature had that but I removed it for simplicity now. Can certainly add it back.

We're trying to standardize on common return codes for all program
types. The lwt bpf series defines BPF_ codes which are compatible
with TC_ACT_* values to make lwt_bpf and cls_bpf compatible. Would
be great to use the same return codes and implement the ones that
make sense.
