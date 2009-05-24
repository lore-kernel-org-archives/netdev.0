From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Sun, 24 May 2009 17:37:44 -0400
Message-ID: <20090524213744.GG24757@kvack.org>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryschenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:37075 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752343AbZEXViS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 17:38:18 -0400
Content-Disposition: inline
In-Reply-To: <200905250023.31056.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2009 at 12:23:30AM +0300, Denys Fedoryschenko wrote:
> Once oprofile gave me hint about similar issue

I forgot to mention: there is no more than ~1% CPU usage while the interfaces 
are being deleted.  I'm about half way through the bisect now and should have 
the culprit soon. 

		-ben
