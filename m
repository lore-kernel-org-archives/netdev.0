From: Graham Murray <gmurray@webwayone.co.uk>
Subject: Re: [PATCH 2/9] sky2: more receive shutdown
Date: Mon, 22 Jun 2009 06:13:02 +0100
Message-ID: <7wbpogc0m9.fsf@gmdev.webwayone.co.uk>
References: <20090617173031.703636683@vyatta.com>
	<20090617173139.582840975@vyatta.com>
	<7wiqirz89f.fsf@gmdev.webwayone.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from procserver.webwayone.co.uk ([62.8.115.202]:40916 "EHLO
	procserver.webwayone.co.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751228AbZFVFNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Jun 2009 01:13:01 -0400
Received: from gmdev.webwayone.co.uk (gmdev.webwayone.co.uk [192.168.50.45])
	by procserver.webwayone.co.uk (8.14.2/8.14.2) with ESMTP id n5M5D2ej007844
	for <netdev@vger.kernel.org>; Mon, 22 Jun 2009 06:13:02 +0100
In-Reply-To: <7wiqirz89f.fsf@gmdev.webwayone.co.uk> (Graham Murray's message
	of "Sat, 20 Jun 2009 08:14:52 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Graham Murray <gmurray@webwayone.co.uk> writes:

> With this this patch applied, the receive on my network card does not
> work from boot. Git bisect identified this as the 'bad' commit and after
> reverting it all works properly.

I should add that there is no panic, BUG, oops etc, nor any other
printk messages, the interface just does not work.
