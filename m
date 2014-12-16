From: Willy Tarreau <w@1wt.eu>
Subject: Re: VLAN bridge patches backported to 2.6.x ?
Date: Tue, 16 Dec 2014 19:59:09 +0100
Message-ID: <20141216185909.GA7122@1wt.eu>
References: <CAKrgqt3rMUnkQChTE+_HDiTHx++bp8MWcQ_xp7-Y3tbFznTKMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Ajit Warrier <ajit.warrier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:4592 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751043AbaLPS7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 13:59:10 -0500
Content-Disposition: inline
In-Reply-To: <CAKrgqt3rMUnkQChTE+_HDiTHx++bp8MWcQ_xp7-Y3tbFznTKMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 07, 2014 at 11:25:18AM -0800, Ajit Warrier wrote:
> The VLAN aware bridge was introduced to the Linux mainline on the 3.x kernels:
> 
> http://lwn.net/Articles/538877/
> 
> Has this feature been backported to the 2.6.x kernels by anybody ? The
> official linux 2.6.32.64 does not have this feature.

No, we only backport fixes to 2.6.32, not new features. Such a large
patchset could definitely break working setups for various reasons ranging
from incompatibilities to errors in backports. So that's definitely not
something supposed to happen for 2.6.32.

Regards,
Willy
