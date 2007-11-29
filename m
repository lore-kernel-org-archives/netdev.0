From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC] [1/9] Core module symbol namespaces code and intro.
Date: Thu, 29 Nov 2007 11:21:58 +0100
Message-ID: <200711291122.00324.arnd@arndb.de>
References: <20071122343.446909000@suse.de> <200711291055.02056.arnd@arndb.de> <200711291100.46598.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	sam@ravnborg.org, rusty@rustcorp.com.au
To: Andi Kleen <ak@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:49748 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762490AbXK2KW0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 05:22:26 -0500
In-Reply-To: <200711291100.46598.ak@suse.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 29 November 2007, Andi Kleen wrote:
> > I think it would be good if you could specify a default namespace
> > per module, that could reduce the amount of necessary changes significantly.
> 
> But also give less documentation. It's also not that difficult to mark
> the exports once. I've forward ported such patches over a few kernels
> and didn't run into significant me

Part of your sentence seems to be missing, but I guess I understand your
point. How many files did you annotate this way? I can see it as being
useful to have the namespace explicit in each symbol, but doing it once
per module sounds like the 80% solution for 20% of the work, and the
two don't even conflict. In the current kernel, I count 12644 exported
symbols in 1646 files, in 540 directories.

One problem I can see with annotating every symbol is that it conflicts
with other patches that add more exported functions to a file without
adding the namespace, or that simply break because of context changes.

	Arnd <><
