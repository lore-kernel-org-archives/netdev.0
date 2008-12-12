From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] e1000e: fix double release of mutex
Date: Thu, 11 Dec 2008 21:28:28 -0800 (PST)
Message-ID: <20081211.212828.49279391.davem@davemloft.net>
References: <20081212052025.3298.151.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@kernel.org,
	linux-kernel@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45601
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751075AbYLLF21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 00:28:27 -0500
In-Reply-To: <20081212052025.3298.151.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 11 Dec 2008 21:20:26 -0800

> During a reset, releasing the swflag after it failed to be acquired would
> cause a double unlock of the mutex.  Instead, test whether acquisition of
> the swflag was successful and if not, do not release the swflag.  The reset
> must still be done to bring the device to a quiescent state.
> 
> This resolves [BUG 12200] BUG: bad unlock balance detected! e1000e
> http://bugzilla.kernel.org/show_bug.cgi?id=12200
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks for respinning this.
