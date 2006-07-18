From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Netchannles: first stage has been completed. Further ideas.
Date: Tue, 18 Jul 2006 23:08:01 +0400
Message-ID: <20060718190801.GA28540@2ka.mipt.ru>
References: <20060718081625.GA13830@2ka.mipt.ru> <20060718121517.GB28291@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:58554 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S932379AbWGRUEo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2006 16:04:44 -0400
To: J?rn Engel <joern@wohnheim.fh-wedel.de>
Content-Disposition: inline
In-Reply-To: <20060718121517.GB28291@wohnheim.fh-wedel.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 18, 2006 at 02:15:17PM +0200, J?rn Engel (joern@wohnheim.fh-wedel.de) wrote:
> 
> Your description makes it sound as if you would take a huge leap,
> changing all in-kernel code _and_ the userspace interface in a single
> patch.  Am I wrong?  Or am I right and would it make sense to extract
> small incremental steps from your patch similar to those Van did in
> his non-published work?

My first implementation used existing kernel code and showed small
performance win - there was binding of the socket to netchannel and all
protocol processing was moved into process context. It actually is the
same what IBM folks do, but my investigation showed that linux sending
side has some issues which would not allow to grow speed very noticebly
(after creating yet another congestion control algo I now think that the
problem is there, but I'm not 100% sure).
And after looking into Van's presentation (and his words about
_userspace_ protocol processing) I think they used own stack too.
So I reinvented the wheel and created my own too.

> J?rn
> 
> -- 
> When people work hard for you for a pat on the back, you've got
> to give them that pat.
> -- Robert Heinlein

-- 
	Evgeniy Polyakov
