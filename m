From: David Decotigny <decot@google.com>
Subject: Re: [PATCH 2/2] forcedeth: allow to silence tx_timeout debug messages
Date: Wed, 18 May 2011 14:43:58 -0700
Message-ID: <BANLkTinG4K-bWS1qqBr_G9mK5OHDYknszg@mail.gmail.com>
References: <1305753000-14933-1-git-send-email-decot@google.com>
 <1305753000-14933-2-git-send-email-decot@google.com> <20110518.171603.2048423328863525352.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Joe Perches <joe@perches.com>, szymon@janc.net.pl,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-net-upstream@google.com, Sameer Nanda <snanda@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:25907 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755823Ab1ERVoV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 17:44:21 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p4ILiJGr013936
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 14:44:20 -0700
Received: from qwa26 (qwa26.prod.google.com [10.241.193.26])
	by wpaz29.hot.corp.google.com with ESMTP id p4ILiD5M001504
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 18 May 2011 14:44:18 -0700
Received: by qwa26 with SMTP id 26so1498444qwa.14
        for <netdev@vger.kernel.org>; Wed, 18 May 2011 14:44:18 -0700 (PDT)
In-Reply-To: <20110518.171603.2048423328863525352.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

No problem, I will send the patch series correctly numbered. Sorry for that.

Regarding your comment about this debug info change:

On Wed, May 18, 2011 at 2:16 PM, David Miller <davem@davemloft.net> wrote:
> You can add a knob which when enabled gives the old verbosity
> back for diagnostic purposes.

That was the intent of this patch: it adds a debug_tx_timeout module
parameter to act as the knob. I can rephrase the description of the
patch, it didn't make this so clear.
Or are you suggesting I should implement this with another kind of knob?

Thanks!
