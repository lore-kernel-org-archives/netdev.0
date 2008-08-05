From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 11:04:53 +0000
Message-ID: <20080805110453.GA6541@ff.dom.local>
References: <200808051305.41064.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.224]:32693 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753957AbYHEK73 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 06:59:29 -0400
Received: by wr-out-0506.google.com with SMTP id 69so1820944wri.5
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 03:59:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <200808051305.41064.denys@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05-08-2008 12:05, Denys Fedoryshchenko wrote:
> I found, that packetloss happening when i am deleting/adding classes.
> I attach result of oprofile as file.
...

Deleting of estimators (gen_kill_estimator) isn't optimized for
a large number of them, and it's a known issue. Adding of classes
shouldn't be such a problem, but maybe you could try to do this
before adding filters directing to those classes.

Since you can control rate with htb, I'm not sure you really need
policing: at least you could try if removing this changes anything.
And I'm not sure: do these tx hangs happen only when classes are
added/deleted or otherwise too?

Jarek P.
