From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 1/2 -next] r8169: allocate with GFP_KERNEL flag when able
 to sleep
Date: Thu, 23 Sep 2010 23:20:12 +0200
Message-ID: <20100923212012.GA10925@electric-eye.fr.zoreil.com>
References: <1285243291-4520-1-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 158.13.115-78.rev.gaoland.net ([78.115.13.158]:38963 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752555Ab0IWVUu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 17:20:50 -0400
Content-Disposition: inline
In-Reply-To: <1285243291-4520-1-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stanislaw Gruszka <sgruszka@redhat.com> :
> We have fedora bug report where driver fail to initialize after
> suspend/resume because of memory allocation errors:
> https://bugzilla.redhat.com/show_bug.cgi?id=629158
> 
> To fix use GFP_KERNEL allocation where possible. 

Feel free to add a Acked-by: Francois Romieu <romieu@fr.zoreil.com>
as soon as it will have been explicitely reported to improve the
situation (it is not clear in the PR above).

-- 
Ueimor
