From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/3] ifb: move tq from ifb_private
Date: Sat, 04 Dec 2010 09:59:53 -0500
Message-ID: <1291474793.2159.43.camel@mojatatu>
References: <1291442121-3302-1-git-send-email-xiaosuo@gmail.com>
	 <1291442121-3302-3-git-send-email-xiaosuo@gmail.com>
	 <1291472282.2159.8.camel@mojatatu> <1291473756.2159.31.camel@mojatatu>
	 <AANLkTikeECFUf0xiug7G+nd5=Sw7p=4Msz6RQ2gdOBzs@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw0-f42.google.com ([74.125.83.42]:35793 "EHLO
	mail-gw0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754336Ab0LDO77 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Dec 2010 09:59:59 -0500
Received: by gwb20 with SMTP id 20so5349901gwb.1
        for <netdev@vger.kernel.org>; Sat, 04 Dec 2010 06:59:59 -0800 (PST)
In-Reply-To: <AANLkTikeECFUf0xiug7G+nd5=Sw7p=4Msz6RQ2gdOBzs@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-12-04 at 22:50 +0800, Changli Gao wrote:

> Maybe you misread my patch. tq is a stack variable in ri_tasklet, and
> initialized all the time. ri_tasklet() won't exits until tq is
> empty().

in your patch is a variable on the stack.
What i am saying is you should defer processing when there is an
error (note the two other spots i mentioned). 
This means you may leave dp->tq non-empty and therefore it
needs to be saved somewhere as it is before your patch.

cheers,
jamal

