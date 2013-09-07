From: Joseph Gasparakis <joseph.gasparakis@intel.com>
Subject: Re: [net-next v4] vxlan: Notify drivers for listening UDP port
 changes
Date: Fri, 6 Sep 2013 17:09:33 -0700 (PDT)
Message-ID: <alpine.LFD.2.03.1309061708540.21291@intel.com>
References: <1378286019-8719-1-git-send-email-jeffrey.t.kirsher@intel.com> <522A5FA9.7000001@redhat.com> <alpine.LFD.2.03.1309061629420.21291@intel.com> <20130906165043.1c8a2442@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com,
	sassmann@redhat.com, John Fastabend <john.r.fastabend@intel.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:51628 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750752Ab3IFXya (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 19:54:30 -0400
In-Reply-To: <20130906165043.1c8a2442@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 6 Sep 2013, Stephen Hemminger wrote:

> On Fri, 6 Sep 2013 16:42:26 -0700 (PDT)
> Joseph Gasparakis <joseph.gasparakis@intel.com> wrote:
> 
> > That is correct, I started assuming dev will be a valid pointer, but then 
> > I thought I shouldn't trust the caller, so I ended up with this. In fact I 
> > have some upcoming sparse fixes too, so I will incorporate all this in one 
> > patch. For this particular comment I will be checking dev first and 
> > assigning net and vn after that.
> 
> This is the kernel, audit the callers. We don't add random null
> pointer checks because that is worse. It creates random error paths
> to validate.
> 

Will do. Thanks!
