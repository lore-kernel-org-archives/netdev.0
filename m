From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 1/2] vxlan: Follow kernel defaults for outer
 UDP checksum.
Date: Sun, 27 Mar 2016 11:01:49 -0700
Message-ID: <20160327110149.2799135f@xeon-e3>
References: <1458348669-48437-1-git-send-email-jesse@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:34567 "EHLO
	mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752659AbcC0SBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2016 14:01:33 -0400
Received: by mail-pf0-f170.google.com with SMTP id x3so119976668pfb.1
        for <netdev@vger.kernel.org>; Sun, 27 Mar 2016 11:01:33 -0700 (PDT)
In-Reply-To: <1458348669-48437-1-git-send-email-jesse@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Mar 2016 17:51:08 -0700
Jesse Gross <jesse@kernel.org> wrote:

> On recent kernels, UDP checksum computation has become more efficient and
> the default behavior was changed, however, the ip command overrides this
> by always specifying a particular behavior.
> 
> If the user does not specify that UDP checksums should either be computed
> or not then we don't need to send an explicit netlink message - the kernel
> can just use its default behavior.
> 
> Signed-off-by: Jesse Gross <jesse@kernel.org>
> ---

Applied both, thanks
