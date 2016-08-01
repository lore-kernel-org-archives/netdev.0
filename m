From: Phil Sutter <phil@nwl.cc>
Subject: Re: [PATCH 1/3] sctp: Export struct sctp_info to userspace
Date: Mon, 1 Aug 2016 15:36:06 +0200
Message-ID: <20160801133606.GB10443@orbyte.nwl.cc>
References: <1469811580-32429-1-git-send-email-phil@nwl.cc>
 <1469811580-32429-2-git-send-email-phil@nwl.cc>
 <20160731141824.30785573@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Xin Long <lucien.xin@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:35843 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751153AbcHANnf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Aug 2016 09:43:35 -0400
Content-Disposition: inline
In-Reply-To: <20160731141824.30785573@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

On Sun, Jul 31, 2016 at 02:18:24PM -0700, Stephen Hemminger wrote:
> On Fri, 29 Jul 2016 18:59:38 +0200
> Phil Sutter <phil@nwl.cc> wrote:
> 
> > This is required to correctly interpret INET_DIAG_INFO messages exported
> > by sctp_diag module.
> > 
> > Signed-off-by: Phil Sutter <phil@nwl.cc>
> 
> You need to add sctp.h to include/linux/Kbuild to get it exported correctly

Thanks for the heads-up! Luckily it is in there already.

Cheers, Phil
