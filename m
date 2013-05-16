From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFT] vxlan: listen on multiple ports
Date: Thu, 16 May 2013 10:51:13 +0800
Message-ID: <1368672673.12751.19.camel@cr0>
References: <1368616270-5775-1-git-send-email-amwang@redhat.com>
	 <OFA8084FAB.8443890D-ON85257B6C.003F1FAB-85257B6C.003F65F2@us.ibm.com>
	 <20130515095322.275c9b2f@nehalam.linuxnetplumber.net>
	 <OFF100C7ED.6500FAB3-ON85257B6C.005DCF7C-85257B6C.005F309B@us.ibm.com>
	 <20130515104825.5cbeaee3@nehalam.linuxnetplumber.net>
	 <OF1177AC77.13B8F09E-ON85257B6C.0064777A-85257B6C.0066B974@us.ibm.com>
	 <20130515143702.38730c3d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Stevens <dlstevens@us.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62539 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754323Ab3EPCvU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 22:51:20 -0400
In-Reply-To: <20130515143702.38730c3d@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 14:37 -0700, Stephen Hemminger wrote:
> The earlier change to introduce per-vxlan UDP port configuration did only
> half the necessary work. It added per vxlan destination for sending, but
> overlooked the handling of multiple ports for incoming, which means it
> is broken.
> 
> This patch changes the listening port management to handle multiple
> incoming UDP ports. The earlier per-namespace structure is now a hash
> list per namespace.
> 
> It is also now possible to define the same virtual network id
> but with different UDP port values.
> 

Besides fixing the default port issue, what other benefits does it have?
This seems overkill.

It looks like you make one socket per port, after my IPv6 patches, we
would have two sockets per port...
