From: James Morris <jmorris@namei.org>
Subject: RE: [PATCH 00/11] The _entire_ secid reconciliation patchset (tada!)
Date: Thu, 12 Oct 2006 03:26:53 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0610120321200.25038@d.namei>
References: <001101c6ed6a$43ae71e0$cc0a010a@tcssec.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paul Moore <paul.moore@hp.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov,
	Venkat Yekkirala <vyekkirala@tcsfw4.tcs-sec.com>,
	Stephen Smalley <sds@tycho.nsa.gov>,
	Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.sea5.speakeasy.net ([69.17.117.3]:25308 "EHLO
	mail1.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1030693AbWJLH05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Oct 2006 03:26:57 -0400
To: Venkat Yekkirala <vyekkirala@trustedcs.com>
In-Reply-To: <001101c6ed6a$43ae71e0$cc0a010a@tcssec.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 11 Oct 2006, Venkat Yekkirala wrote:

> > Outstanding items include resolving the igmp skb hook issue 
> > generally, 
> > testing to verify both the design and implementation, and 
> > ensuring that 
> > all the related policy changes are merged upstream first.
> > 
> Regarding the igmp hook issue, we could do a generic hook
> like Paul suggested. Would that be more palatable you think?

It needs to be investigated to see if anything else in the kernel is doing 
the same thing, and then most likely, a generic hook for 
classifying non-socket packets (you could pass the protocol as a hook 
parameter).


-- 
James Morris
<jmorris@namei.org>
