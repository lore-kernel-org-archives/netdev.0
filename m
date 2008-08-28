From: Eugene Teo <eteo@redhat.com>
Subject: Re: [PATCH 1/2] sctp: correct bounds check in sctp_setsockopt_auth_key
Date: Thu, 28 Aug 2008 08:01:45 +0800
Message-ID: <48B5EAE9.9090704@redhat.com>
References: <48B42ECA.7010800@redhat.com> <12198674162757-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, security@kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34822 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752152AbYH1ACR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 20:02:17 -0400
In-Reply-To: <12198674162757-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich wrote:
> The bonds check to prevent buffer overlflow was not exactly
> right.  It still allowed overflow of up to 8 bytes which is
> sizeof(struct sctp_authkey).
> 
> Since optlen is already checked against the size of that struct,
> we are guaranteed not to cause interger overflow either.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Acked-by: Eugene Teo <eugeneteo@kernel.sg>

Eugene
