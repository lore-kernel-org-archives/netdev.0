From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH 2/7] cxgb3 - fix netpoll hanlder
Date: Wed, 30 May 2007 09:06:27 -0700
Message-ID: <465DA103.6090100@goop.org>
References: <20070526225952.12115.30971.stgit@localhost.localdomain> <465B591B.1010507@garzik.org> <465CBE4B.9070009@goop.org> <465CC870.7050407@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: divy@chelsio.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:52238 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756349AbXE3QGW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 12:06:22 -0400
In-Reply-To: <465CC870.7050407@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Look at the function argument... 

Yes, it's void *.  But my point is that C requires the ?: to evaluate to
some specific type, so if you have different types on each side of the :
the compiler can be legitimately upset.  The fact that the whole thing
gets cast to void * is somewhat irrelevant.

    J
