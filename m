From: Andi Kleen <andi@firstfloor.org>
Subject: Re: A question about hh_cache
Date: Sun, 30 Dec 2007 16:36:26 +0100
Message-ID: <20071230153626.GA32752@one.firstfloor.org>
References: <147a89290712300531m4a8845betd23ef71f6d944799@mail.gmail.com> <p73abns1be1.fsf@bingen.suse.de> <147a89290712300712p5c586f57wff1b29e9fa807dee@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, netdev@vger.kernel.org
To: Andy Johnson <johnsonzjo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:39633 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbXL3Per (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2007 10:34:47 -0500
Content-Disposition: inline
In-Reply-To: <147a89290712300712p5c586f57wff1b29e9fa807dee@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 30, 2007 at 05:12:05PM +0200, Andy Johnson wrote:
> Can there be a case in such environment (using IPv4 only) where
> hh_cache of a neighbour instance is a
> list with more than one entry ?

In theory if some device supplies own multiple dst_ops with different 
protocol numbers.  From a quick grep doesn't happen in tree.

-Andi
