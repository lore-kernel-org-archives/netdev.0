From: Hisashi T Fujinaka <htodd@twofifty.com>
Subject: Re: [PATCH] e1000e: Cleanup handling of VLAN_HLEN as a part of max
 frame size
Date: Wed, 8 Apr 2015 14:15:43 -0700 (PDT)
Message-ID: <alpine.NEB.2.11.1504081413510.3388@chris.i8u.org>
References: <alpine.NEB.2.11.1504081019220.3388@chris.i8u.org> <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: intel-wired-lan@lists.osuosl.org, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, mike@cchtml.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-148-87-25-Oregon.hfc.comcastbusiness.net ([75.148.87.25]:40064
	"EHLO chris.i8u.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbbDHVPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 17:15:44 -0400
In-Reply-To: <20150408204630.4643.37880.stgit@ahduyck-vm-fedora22>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 8 Apr 2015, Alexander Duyck wrote:

> Fixes: c751a3d58cf2d ("e1000e: Correctly include VLAN_HLEN when changing interface MTU")
> Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
> ---
>
> I have only build tested this though I am 99% sure the fixes here are
> correct.  This patch should fix issues on 82573 and ich8 w/ setting an MTU
> of 1500, and for the PCH series w/ setting an MTU of 9000.

Since the original fix was something submitted by Red Hat, can you check
that you're not re-breaking whatever it was that Red Hat thought they
were fixing?
