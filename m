From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [patch] econet: unlock on -EPERM path
Date: Tue, 07 Dec 2010 23:01:38 +0100
Message-ID: <4CFEAEC2.7080506@gmail.com>
References: <20101207110138.GM10623@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Blundell <philb@gnu.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:61794 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753275Ab0LGWBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 17:01:47 -0500
In-Reply-To: <20101207110138.GM10623@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dan Carpenter wrote:
> We need to do a mutex_unlock() and a put_dev() before returning.

Good catch! Btw, isn't this put_dev() below, in case SIOCGIFADDR,
superfluous?

Jarek P.
