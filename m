From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 11:15:45 +0000
Message-ID: <20080826111545.GD2609@ff.dom.local>
References: <20080826095126.GA2609@ff.dom.local> <200808261329.53741.denys@visp.net.lb> <20080826104717.GB2609@ff.dom.local> <200808261349.09820.denys@visp.net.lb> <20080826110746.GC2609@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:14613 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753459AbYHZLPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 07:15:52 -0400
Received: by ug-out-1314.google.com with SMTP id c2so713687ugf.37
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2008 04:15:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080826110746.GC2609@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 26, 2008 at 11:07:46AM +0000, Jarek Poplawski wrote:
> On Tue, Aug 26, 2008 at 01:49:09PM +0300, Denys Fedoryshchenko wrote:
...
> > Maybe it can be optional, and enabled via kernel parameter and /sys , so it 
> > can be useful in case of crashes when TSC used and when timer is too slow.
> > Because it is not so useful just to disable hrtimers completely, if you need 
> > them for some other task...
> 
> Maybe it could be enough to use current parameters like: "highres=off"
> according to Documentation/kernel-parameters.txt?

Hmm.. it isn't actually answer to your question, sorry. As I said
before I think we need to have more people interested in using such
additional options, and btw. I understood from your message that 
disabling htb didn't solve the problem?

Jarek P.
