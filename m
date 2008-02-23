From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC PATCH 0/8]: uninline & uninline
Date: Sat, 23 Feb 2008 00:02:20 -0800
Message-ID: <20080223000220.e9229c99.akpm@linux-foundation.org>
References: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: =?ISO-8859-1?B?IklscG8gSuRydmluZW4i?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:55161 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757852AbYBWIDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 03:03:37 -0500
In-Reply-To: <1203515238-22848-1-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 20 Feb 2008 15:47:10 +0200 "Ilpo J__rvinen" <ilpo.jarvinen@helsinki.fi> wrote:

> Ok, here's the top of the list (10000+ bytes):

This is good stuff - thanks.

> -41525  2066 f, 3370 +, 44895 -, diff: -41525  IS_ERR 

This is a surprise.  I expect that the -mm-only
profile-likely-unlikely-macros.patch is the cause of this and mainline
doesn't have this problem.

If true, then this likely/unlikely bloat has probably spread into a lot of
your other results and it all should be redone against mainline, sorry :(

(I'm not aware of anyone having used profile-likely-unlikely-macros.patch
in quite some time.  That's unfortunate because it has turned up some
fairly flagrant code deoptimisations)
