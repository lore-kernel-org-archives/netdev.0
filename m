From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC] Arp announce (for Xen)
Date: Fri, 02 Mar 2007 09:08:38 -0500
Message-ID: <1172844518.4864.42.camel@localhost>
References: <20070301232443.195603797@goop.org>
	 <20070301232529.648076372@goop.org> <20070301164214.4a40bc59@freekitty>
	 <45E7764A.7000100@goop.org> <20070301173030.754514ec@freekitty>
	 <20070302125428.GA67405@muc.de>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, virtualization@lists.osdl.org,
	xen-devel@lists.xensource.com, Chris Wright <chrisw@sous-sol.org>,
	Zachary Amsden <zach@vmware.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Ian Pratt <ian.pratt@xensource.com>,
	Christian Limpach <Christian.Limpach@cl.cam.ac.uk>,
	netdev@vger.kernel.org, Jeff Garzik <jeff@garzik.org>
To: Andi Kleen <ak@muc.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nz-out-0506.google.com ([64.233.162.231]:31460 "EHLO
	nz-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992461AbXCBOIm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 09:08:42 -0500
Received: by nz-out-0506.google.com with SMTP id s1so863935nze
        for <netdev@vger.kernel.org>; Fri, 02 Mar 2007 06:08:41 -0800 (PST)
In-Reply-To: <20070302125428.GA67405@muc.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2007-02-03 at 13:54 +0100, Andi Kleen wrote:

> Seems like the right solution to me (if it works)

I like it as well given the simple change. 
These are the kind of optimizations that justify offloading things to
the kernel (instead of user space) i.e very little lines of code, covers
a large number of user-desires, and can be turned off if you want to do
something complex. _Almost_ elegant Stephen;->

cheers,
jamal

