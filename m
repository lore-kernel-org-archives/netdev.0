From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/4] qlcnic: use standard NAPI weights
Date: Wed, 21 Aug 2013 22:19:04 +0400
Message-ID: <52150498.1090805@cogentembedded.com>
References: <1377103771-1590-1-git-send-email-mschmidt@redhat.com> <1377103771-1590-5-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Eric Dumazet <edumazet@google.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	linux-driver@qlogic.com
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:34455 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751688Ab3HUSS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 14:18:59 -0400
Received: by mail-la0-f42.google.com with SMTP id ep20so643988lab.29
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 11:18:57 -0700 (PDT)
In-Reply-To: <1377103771-1590-5-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/21/2013 08:49 PM, Michal Schmidt wrote:

> Since commit 82dc3c63 netif_napi_add() produces an error message if

    Likewise, summary line is needed.

> a NAPI poll weight greater than 64 is requested.

> qlcnic requests the weight as large as 256 for some of its rings, and
> smaller values for other rings. For instance in qlcnic_82xx_napi_add()
> I think the intention was to give the tx+rx ring a bigger weight than
> to rx-only rings, but it's actually doing the opposite. So I'm assuming
> the weights do not really matter much.

> Just use the standard NAPI weights for all rings.

> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
> CC: Himanshu Madhani <himanshu.madhani@qlogic.com>
> CC: Rajesh Borundia <rajesh.borundia@qlogic.com>
> CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
> CC: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
> CC: Sony Chacko <sony.chacko@qlogic.com>
> CC: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
> CC: linux-driver@qlogic.com

WBR, Sergei
