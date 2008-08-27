From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] sctp: correct bounds check in
 sctp_setsockopt_auth_key
Date: Wed, 27 Aug 2008 16:09:15 -0700 (PDT)
Message-ID: <20080827.160915.57923023.davem@davemloft.net>
References: <48B42ECA.7010800@redhat.com>
	<12198674162757-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eteo@redhat.com, netdev@vger.kernel.org, security@kernel.org,
	linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50902
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753925AbYH0XJU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 19:09:20 -0400
In-Reply-To: <12198674162757-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 27 Aug 2008 16:03:34 -0400

> The bonds check to prevent buffer overlflow was not exactly
> right.  It still allowed overflow of up to 8 bytes which is
> sizeof(struct sctp_authkey).
> 
> Since optlen is already checked against the size of that struct,
> we are guaranteed not to cause interger overflow either.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, and queued for -stable.
