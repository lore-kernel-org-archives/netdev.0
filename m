From: Benjamin LaHaise <bcrl@lhnet.ca>
Subject: Re: regression: unregister_netdev() unusably slow
Date: Sun, 24 May 2009 18:12:40 -0400
Message-ID: <20090524221240.GI24757@kvack.org>
References: <20090524192150.GE24757@kvack.org> <200905250023.31056.denys@visp.net.lb> <20090524213744.GG24757@kvack.org> <4A19BF39.4000305@cosmosbay.com> <20090524214433.GH24757@kvack.org> <4A19C50B.9040304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Denys Fedoryschenko <denys@visp.net.lb>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:37996 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759903AbZEXWMu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 24 May 2009 18:12:50 -0400
Content-Disposition: inline
In-Reply-To: <4A19C50B.9040304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 25, 2009 at 12:07:07AM +0200, Eric Dumazet wrote:
> Maybe your HZ is too low ? Changing to 1000 HZ helps a lot

HZ is set to 1000.  I turned off CONFIG_NO_HZ

> Also your hotplug config might do strange things at device removal ?

If it were CPU bound, maybe, but this behaviour is tied to the kernel 
version in use.

> What distro do you use ?

It's an older Fedora 7 install inside kvm on a Fedora 10 host running 
2.6.30-rc7.

		-ben
