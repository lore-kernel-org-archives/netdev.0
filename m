From: "Adam Langley" <agl@imperialviolet.org>
Subject: Re: net-2.6 being rebased...
Date: Tue, 3 Jun 2008 15:09:39 -0700
Message-ID: <396556a20806031509y3d2bb981rdb1f50ad60fc83c6@mail.gmail.com>
References: <20080603.142407.08652094.davem@davemloft.net>
	 <20080603.142840.134267001.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, linville@tuxdriver.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.231]:63966 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753310AbYFCWJk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 18:09:40 -0400
Received: by rv-out-0506.google.com with SMTP id l9so1794476rvb.1
        for <netdev@vger.kernel.org>; Tue, 03 Jun 2008 15:09:40 -0700 (PDT)
In-Reply-To: <20080603.142840.134267001.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 3, 2008 at 2:28 PM, David Miller <davem@davemloft.net> wrote:
> The rebase of net-2.6 is complete, thanks for your understanding.

I should apologise for this. I don't know the TCP stack well enough
(obviously); I just sought to highlight a bug that I saw when I was
hacking around for one of my own pet projects.

I'll send a v2 patch in a second which should contain all the first,
plus fixes at all the other places I can find that the contents of the
header are calculated. (I've tested it between a couple of KVM
instances, which is all the testing ability I have at the moment). You
may well want to drop it and wait until someone competent comes along
to fix it.


-- 
Adam Langley agl@imperialviolet.org http://www.imperialviolet.org
