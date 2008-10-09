From: Brice Goglin <brice@myri.com>
Subject: Re: myri10ge: rename main file into myri10ge_main.c
Date: Thu, 09 Oct 2008 13:54:07 +0200
Message-ID: <48EDF0DF.8020306@myri.com>
References: <20081008.162126.191961537.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1947 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756784AbYJILwi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 07:52:38 -0400
In-Reply-To: <20081008.162126.191961537.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> I'm not applying this patch nor the one that does the
> actual split up.
>
> Single file drivers are so much easier to maintain and
> hack on, multi-file drivers are heavily discouraged.
>
> If I want to change some structure member in a multi-file
> driver I have go over seperate files instead of doing a
> single search and replace operation in a single editing
> buffer.
>
> Drivers like e1000, cxgb3 (especially cxgb3!) are such a pain
> in the ass to study and make changes to for this reason.  Please
> don't add myri10ge to this group.
>   


Oh, I wrongly thought people liked small pieces since most new drivers
come in multiple files these days.
So yeah, we're not splitting anymore :)

Brice

