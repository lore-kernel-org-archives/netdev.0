From: Tom Parkin <tom.parkin@gmail.com>
Subject: Re: [PATCH 0/4] l2tp: fix up network namespace use in l2tp_core
Date: Thu, 10 Jan 2013 16:48:57 +0000
Message-ID: <CACzvQmZFJeFKO-2mveT+QyDHQk3yx9ph4b+3YJCyMQ-N6MgwFQ@mail.gmail.com>
References: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Tom Parkin <tparkin@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f180.google.com ([74.125.82.180]:40332 "EHLO
	mail-we0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751224Ab3AJQs7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2013 11:48:59 -0500
Received: by mail-we0-f180.google.com with SMTP id t57so365327wey.39
        for <netdev@vger.kernel.org>; Thu, 10 Jan 2013 08:48:58 -0800 (PST)
In-Reply-To: <1357756583-22535-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9 January 2013 18:36, Tom Parkin <tparkin@katalix.com> wrote:
> This patchset addresses network namespace issues in l2tp_core as previously
> raised on netdev[1].

Bah, please ignore this changeset for now.  I have just discovered a
late change I made to support preemption-enabled kernels breaks the
non-preempt case.  I need to reconsider tunnel deletion to properly
address this.

Apologies,
Tom
--
Tom Parkin
www.thesecretdogproject.com
The competent programmer is fully aware of the strictly limited size
of his own skull; therefore he approaches the programming task in full
humility, and among other things he avoids clever tricks like the
plague. /E. W. Dijkstra/
