From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Wed, 4 Oct 2006 18:07:05 +0200
Message-ID: <200610041807.05266.IvDoorn@gmail.com>
References: <4523DA7D.2080604@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.188]:57211 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161483AbWJDQH6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 12:07:58 -0400
Received: by nf-out-0910.google.com with SMTP id x30so525799nfb
        for <netdev@vger.kernel.org>; Wed, 04 Oct 2006 09:07:57 -0700 (PDT)
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <4523DA7D.2080604@web.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

> Ivo told me about a patch for d80211 that moved certain timers to thread
> context, effectively avoiding to call config from timer handlers, but I
> didn't find any trace yet. Is there some modification in this direction
> already scheduled? I'm not necessarily looking for work, at best I would
> just enjoy to use it. ;)

I have found the actual patch:
[PATCH 1/5] d80211: make sleeping in hw->config possible
And was send on august 1st by Jiri to the netdev list.
It was based on a patch by Michael Buesch.

Ivo
