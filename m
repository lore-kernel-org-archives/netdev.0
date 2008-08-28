From: Eugene Teo <eteo@redhat.com>
Subject: Re: [PATCH 2/2] sctp: fix random memory dereference with SCTP_HMAC_IDENT
 option.
Date: Thu, 28 Aug 2008 08:02:19 +0800
Message-ID: <48B5EB0B.2030604@redhat.com>
References: <48B42ECA.7010800@redhat.com> <12198674171396-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, security@kernel.org,
	linux-sctp@vger.kernel.org
To: Vlad Yasevich <vladislav.yasevich@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34840 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754312AbYH1ACd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 20:02:33 -0400
In-Reply-To: <12198674171396-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich wrote:
> The number of identifiers needs to be checked against the option
> length.  Also, the identifier index provided needs to be verified
> to make sure that it doesn't exceed the bounds of the array.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Acked-by: Eugene Teo <eugeneteo@kernel.sg>

Eugene
