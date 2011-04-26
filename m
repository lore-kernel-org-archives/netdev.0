From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] bql: Byte queue limits
Date: Tue, 26 Apr 2011 16:33:07 +0200
Message-ID: <1303828387.3358.54.camel@edumazet-laptop>
References: <alpine.DEB.2.00.1104252128290.5895@pokey.mtv.corp.google.com>
	 <1303796313.2747.190.camel@edumazet-laptop>
	 <BANLkTi=xTTjcG7CVfCk8sWojRSZhST+e_Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60606 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755900Ab1DZOdM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 10:33:12 -0400
Received: by wya21 with SMTP id 21so501887wya.19
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2011 07:33:11 -0700 (PDT)
In-Reply-To: <BANLkTi=xTTjcG7CVfCk8sWojRSZhST+e_Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 26 avril 2011 =C3=A0 07:13 -0700, Tom Herbert a =C3=A9crit :

> > SMP ???), and why kobj is now guarded by CONFIG_XPS instead of
> > CONFIG_RPS.
> >
> Because that kobj is for transmit side (currently only for xps_cpus)

Please provide a separate patch then, cleanups should be seperated.



