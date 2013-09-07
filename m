From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: sctp: fix smatch warning in sctp_send_asconf_del_ip
Date: Sat, 07 Sep 2013 22:19:17 +0200
Message-ID: <522B8A45.4030005@redhat.com>
References: <1378579881-27881-1-git-send-email-dborkman@redhat.com> <B8C81C0E-1D13-40A9-A39F-4E5C8069366D@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>
To: Michio Honda <micchie@sfc.wide.ad.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2969 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751834Ab3IGUTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 7 Sep 2013 16:19:31 -0400
In-Reply-To: <B8C81C0E-1D13-40A9-A39F-4E5C8069366D@sfc.wide.ad.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2013 09:40 PM, Michio Honda wrote:
> Hi,
>
> Sorry for that I didn't respond to that warning.
> You are right, laddr == NULL && addrcnt == 1 is the indicator of the function called by
> asconf_mgmt().
>
> Since your patch is actually redundant, I would suggest putting comment on the
> line of "if ((laddr == NULL) && (addrcnt == 1)) {", and/or on the checking in your patch.

I think as is is just fine. One can read through the Git log and then see
the rationale behind a change (which is in most cases even more worth than
a comment). If this function should ever be called from somewhere else for
whatever reason, then this comment would already be obsolete.
