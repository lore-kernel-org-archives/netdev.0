From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: I can tell no FIB
Date: Thu, 05 Mar 2015 13:17:54 -0800
Message-ID: <54F8C802.1010706@gmail.com>
References: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
	"mi >> David Miller" <davem@davemloft.net>
To: Scott Feldman <sfeldma@gmail.com>,
	"alexander.h.duyck@redhat.com" <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f180.google.com ([209.85.192.180]:46289 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbbCEVR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 16:17:56 -0500
Received: by pdev10 with SMTP id v10so8937261pde.13
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 13:17:56 -0800 (PST)
In-Reply-To: <CAE4R7bBwrB8==aYuN9gYoADwZHDwr5zYjL3tL=jqPP24p74VUw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/05/2015 12:49 PM, Scott Feldman wrote:
> Hi Alex, turns out you're required to take a mandatory week-long
> vacation after your fourth patch set to net/ipv4/fib_*.  See you in a
> week!  Take lots of pictures.
>
> -scott

Well I have one more set of 9 and then I will stop for a while.  I was
planning to send it later tonight.  Then I can probably take that
week-long vacation..

I'm going to drop the portion of the patches I had where I was
up-levelling the key vector since I still don't have a solution for the
extra costs of insertion/deletion from the trie.  Also I don't think it
would work well with the merge of the main and local tries if that is
the route we are planning to take.

- Alex
