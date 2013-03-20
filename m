From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: [PATCH 1/2] genetlink: trigger BUG_ON if a group name is too long
Date: Wed, 20 Mar 2013 15:17:13 -0700
Message-ID: <CAE9FiQVJhAbvfxp152a0KbzFE1hVQZMNwdWkKnyii3HNWDBd=A@mail.gmail.com>
References: <CAE9FiQXgv8EZGQ142NyV5D1M2+HKSaSoafNzdXY2SBO+iQjdGw@mail.gmail.com>
	<20130320.171305.1359445944793447383.davem@davemloft.net>
	<CAE9FiQX+9NXfVO9P1ZELYjA+D35Tt7r0ngsGZfW9VaU1Q0WJvQ@mail.gmail.com>
	<20130320.181005.1507999596274688798.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: rui.zhang@intel.com, yamato@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:56278 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab3CTWRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 18:17:14 -0400
Received: by mail-ie0-f172.google.com with SMTP id c10so2786821ieb.31
        for <netdev@vger.kernel.org>; Wed, 20 Mar 2013 15:17:13 -0700 (PDT)
In-Reply-To: <20130320.181005.1507999596274688798.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 20, 2013 at 3:10 PM, David Miller <davem@davemloft.net> wrote:

>> so bisecting will be broken?
>
> Good point, so I'll apply the thermal patch to my tree to minimize
> the failure range.

yes, that "second" patch should be applied before this one.
