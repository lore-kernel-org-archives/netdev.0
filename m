From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] bnx2x: increase inner ip id during
 encapsulated tso
Date: Thu, 21 Mar 2013 20:38:51 -0700
Message-ID: <1363923531.4431.55.camel@edumazet-glaptop>
References: <1363916305-15690-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>,
	Maciej Zenczykowski <maze@google.com>,
	Jesse Gross <jesse@nicira.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f48.google.com ([209.85.160.48]:48808 "EHLO
	mail-pb0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753731Ab3CVDiy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 23:38:54 -0400
Received: by mail-pb0-f48.google.com with SMTP id wy12so2718980pbc.7
        for <netdev@vger.kernel.org>; Thu, 21 Mar 2013 20:38:54 -0700 (PDT)
In-Reply-To: <1363916305-15690-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-22 at 03:38 +0200, Dmitry Kravkov wrote:
> 57712/578xx devices during handling of encapsulated TSO can
> properly increase ip id for only one ip header.
> The patch selects inner header to be increased.
> 
> Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>
> CC: Ariel Elior <ariele@broadcom.com>
> CC: Maciej Zenczykowski <maze@google.com>
> CC: Jesse Gross <jesse@nicira.com>
> ---

Thanks for CC me :(

I'll test this in the following hour, thanks!
