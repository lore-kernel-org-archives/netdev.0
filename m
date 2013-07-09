From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [Patch iproute2] iptunnel: check SIT_ISATAP flag only for SIT
 tunnel
Date: Tue, 9 Jul 2013 09:09:08 -0700
Message-ID: <20130709090908.6f2225f7@nehalam.linuxnetplumber.net>
References: <1372757968-21236-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:57199 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752486Ab3GIQl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 12:41:27 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so5766854pab.10
        for <netdev@vger.kernel.org>; Tue, 09 Jul 2013 09:41:26 -0700 (PDT)
In-Reply-To: <1372757968-21236-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue,  2 Jul 2013 17:39:28 +0800
Cong Wang <amwang@redhat.com> wrote:

> Without patch, I got:
> 
> 	# ./ip/ip tunnel show
> 	ip_vti0: ioctl 89f4 failed: Invalid argument
> 	ip_vti0: ip/ip  remote any  local any  ttl inherit  nopmtudisc key 0
> 
> this is due to VTI_ISVTI has the same numeric value with SIT_ISATAP,
> but only sit tunnel has SIOCGETPRL, therefore it should check for SIT
> tunnel first.
> 
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied
