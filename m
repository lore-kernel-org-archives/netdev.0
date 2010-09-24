From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when
 able to sleep
Date: Fri, 24 Sep 2010 13:18:42 +0200
Message-ID: <20100924131842.26f1fb1f@dhcp-lab-109.englab.brq.redhat.com>
References: <1285243291-4520-1-git-send-email-sgruszka@redhat.com>
	<20100923212012.GA10925@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25186 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab0IXLTS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Sep 2010 07:19:18 -0400
In-Reply-To: <20100923212012.GA10925@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Sep 2010 23:20:12 +0200
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stanislaw Gruszka <sgruszka@redhat.com> :
> > We have fedora bug report where driver fail to initialize after
> > suspend/resume because of memory allocation errors:
> > https://bugzilla.redhat.com/show_bug.cgi?id=629158
> > 
> > To fix use GFP_KERNEL allocation where possible. 
> 
> Feel free to add a Acked-by: Francois Romieu <romieu@fr.zoreil.com>
> as soon as it will have been explicitely reported to improve the
> situation (it is not clear in the PR above).

I'm pretty sure patch fix the problem, however yes, we do not have
confirmation from reporter yet. Anyway atomic allocation should not
be used in process context.

Stanislaw
