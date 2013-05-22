From: Roland Dreier <roland@kernel.org>
Subject: Re: tg3 transmit timeout on 5720 / Dell R720
Date: Wed, 22 May 2013 15:02:23 -0700
Message-ID: <CAL1RGDXbMcgox0vuOPzkBOE2vAYKYdP-qXy_nwaaA9GAUruBtA@mail.gmail.com>
References: <1369242151-6821-1-git-send-email-roland@kernel.org> <519D1BDE.9000109@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michael Chan <mchan@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Nithin Nayak Sujir <nsujir@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys010aog109.obsmtp.com ([74.125.245.86]:52530 "HELO
	na3sys010aog109.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756513Ab3EVWCq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 May 2013 18:02:46 -0400
Received: by mail-lb0-f173.google.com with SMTP id t10so2640596lbi.4
        for <netdev@vger.kernel.org>; Wed, 22 May 2013 15:02:44 -0700 (PDT)
In-Reply-To: <519D1BDE.9000109@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -               tp->eee.eee_enabled = 1;
> +               tp->eee.eee_enabled = 0;

Tried latest net-next (5ea94e7686a3) both with and without this patch
and hit the transmit timeout immediately both ways.  (On the one bad
port)

I'll try to find a kernel where tg3 works on this system so I can bisect.

 - R.
