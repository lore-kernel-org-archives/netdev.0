From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 09/11] irda: replace __FUNCTION__ with __func__
Date: Wed, 30 Jul 2008 16:52:07 -0700
Message-ID: <20080730165207.b8e62eb5.akpm@linux-foundation.org>
References: <200807301937.m6UJbgXw012455@imap1.linux-foundation.org>
	<20080730.164236.246400895.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harvey.harrison@gmail.com,
	samuel@sortiz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:54053 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753940AbYG3Xw2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 19:52:28 -0400
In-Reply-To: <20080730.164236.246400895.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Jul 2008 16:42:36 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: akpm@linux-foundation.org
> Date: Wed, 30 Jul 2008 12:37:42 -0700
> 
> > From: Harvey Harrison <harvey.harrison@gmail.com>
> > 
> > __FUNCTION__ is gcc-specific, use __func__
> > 
> > Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> > Cc: Samuel Ortiz <samuel@sortiz.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> This gets rejects because it conflicts with the down_try()
> changes that went into Linus's tree recently.  Specifically
> this occurs in sir_dev.c

urgh, OK, sorry.  I'll hang onto it, see how we get along next time.
