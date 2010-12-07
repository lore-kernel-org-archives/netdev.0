From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [patch] econet: unlock on -EPERM path
Date: Tue, 07 Dec 2010 23:09:41 +0100
Message-ID: <4CFEB0A5.8040506@gmail.com>
References: <20101207110138.GM10623@bicker> <4CFEAEC2.7080506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Phil Blundell <philb@gnu.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63589 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855Ab0LGWJr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Dec 2010 17:09:47 -0500
In-Reply-To: <4CFEAEC2.7080506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> Dan Carpenter wrote:
>> We need to do a mutex_unlock() and a put_dev() before returning.
> 
> Good catch! Btw, isn't this put_dev() below, in case SIOCGIFADDR,
> superfluous?

Hmm... put_dev() a.k.a. dev_put() ;-)

Jarek P.
