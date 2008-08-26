From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 13:29:53 +0300
Message-ID: <200808261329.53741.denys@visp.net.lb>
References: <20080826095126.GA2609@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:37182 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604AbYHZKbW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 06:31:22 -0400
In-Reply-To: <20080826095126.GA2609@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 August 2008, Jarek Poplawski wrote:
>
> This function is really used in many places, and these profiles are
> not enough at least to me, but it seems you could have a lot of
> softirqs (and probably hrtimers) scheduling, so maybe you should try
> if e.g. disabling hrtimers or changing kernel HZ makes any difference.
>
> Jarek P.
One user is shapers, it is ok for me.
I am not sure, but maybe another user is softlockup debug option... and if 
there is a lot of task switches maybe it will cause excessive load of timers 
slow?

