From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 9 Sep 2008 10:22:08 +0400
Message-ID: <20080909062208.GB30385@2ka.mipt.ru>
References: <48C59F75.6030504@redhat.com> <48C5A9A9.9040503@hp.com> <48C6052D.2080203@redhat.com> <20080908.221742.02572583.davem@davemloft.net> <48C60FFC.8090109@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: Chris Snook <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:39094 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753579AbYIIGXs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 02:23:48 -0400
Content-Disposition: inline
In-Reply-To: <48C60FFC.8090109@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Sep 09, 2008 at 01:56:12AM -0400, Chris Snook (csnook@redhat.com) wrote:
> The easiest way to see the problem is to open a TCP socket to an echo 
> daemon on loopback, make a bunch of small writes totaling less than your 
> loopback MTU (accounting for overhead), and see how long it takes to get 
> your echoes.  You can probably do this with netcat, though I haven't 
> tried.  People don't expect loopback to have 40 ms latency when the box 
> is lightly loaded, so they'd really like to tweak that down when it's 
> hurting them.

Isn't Nagle without corking a very bad idea? Or you can not change the
application?

-- 
	Evgeniy Polyakov
