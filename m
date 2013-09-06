From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [net-next v4] vxlan: Notify drivers for listening UDP port
 changes
Date: Fri, 6 Sep 2013 16:50:43 -0700
Message-ID: <20130906165043.1c8a2442@nehalam.linuxnetplumber.net>
References: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<522A5FA9.7000001@redhat.com>
	<alpine.LFD.2.03.1309061629420.21291@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <dborkman@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, John Fastabend <john.r.fastabend@intel.com>
To: Joseph Gasparakis <joseph.gasparakis@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:54429 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754Ab3IFXuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 19:50:46 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so3939864pab.38
        for <netdev@vger.kernel.org>; Fri, 06 Sep 2013 16:50:46 -0700 (PDT)
In-Reply-To: <alpine.LFD.2.03.1309061629420.21291@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 6 Sep 2013 16:42:26 -0700 (PDT)
Joseph Gasparakis <joseph.gasparakis@intel.com> wrote:

> That is correct, I started assuming dev will be a valid pointer, but then 
> I thought I shouldn't trust the caller, so I ended up with this. In fact I 
> have some upcoming sparse fixes too, so I will incorporate all this in one 
> patch. For this particular comment I will be checking dev first and 
> assigning net and vn after that.

This is the kernel, audit the callers. We don't add random null
pointer checks because that is worse. It creates random error paths
to validate.
