From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Pull request for 'r8169-for-jeff-20070919' branch
Date: Fri, 21 Sep 2007 09:08:49 +0200
Message-ID: <20070921070849.GA4502@electric-eye.fr.zoreil.com>
References: <20070919195606.GA3871@electric-eye.fr.zoreil.com> <46F2D24A.6050200@redhat.com> <20070920204437.GB13512@electric-eye.fr.zoreil.com> <46F2E590.1070704@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org,
	akpm@linux-foundation.org, David Gundersen <gundy@iinet.net.au>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Sylvain Le Gall <sylvain@le-gall.net>,
	Roel.Teuwen@advalvas.be
To: Chuck Ebbert <cebbert@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:45976 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750717AbXIUHMQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Sep 2007 03:12:16 -0400
Content-Disposition: inline
In-Reply-To: <46F2E590.1070704@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chuck Ebbert <cebbert@redhat.com> :
[...]
> Looking again, it may not be r8169's fault, but it is involved. It

Sort of:
[...]
* Hung when moving data off a physical disk in an LVM. Twice during night.
* Hung when adding a disk to a software Raid. Once.

> used to hang and could be restarted by pulling the cable and reinserting
> it,

This is already worked around in 2.6.22-stable.

> but now it just locks solid:
> 
> https://bugzilla.redhat.com/show_bug.cgi?id=252955

A part of it look like the usual samba + 816x failure. The most recent
changeset in the patch submitted for inclusion should be applied.

-- 
Ueimor
