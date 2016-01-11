From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [iproute2 1/1] tc: flower no need to specify the ethertype
Date: Mon, 11 Jan 2016 08:27:03 -0800
Message-ID: <20160111082703.5791cf5f@xeon-e3>
References: <1452455791-5833-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33515 "EHLO
	mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932892AbcAKQ04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jan 2016 11:26:56 -0500
Received: by mail-pf0-f178.google.com with SMTP id e65so47111968pfe.0
        for <netdev@vger.kernel.org>; Mon, 11 Jan 2016 08:26:56 -0800 (PST)
In-Reply-To: <1452455791-5833-1-git-send-email-jhs@emojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 10 Jan 2016 14:56:31 -0500
Jamal Hadi Salim <jhs@mojatatu.com> wrote:

> From: Jamal Hadi Salim <jhs@mojatatu.com>
> 
> since all tc classifiers are required to specify ethertype as part of grammar
> By not allowing eth_type to be specified we remove contradiction for 
> example when a user specifies:
> tc filter add ... priority xxx protocol ip flower eth_type ipv6
> This patch removes that contradiction
> 

Applied thanks.
Does man page need an update as well?
