From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH] Add IPv6 support to TCP SYN cookies
Date: Tue, 5 Feb 2008 15:42:13 +0000
Message-ID: <20080205154213.059ac6e8@core>
References: <47a79d64.16538c0a.5b6a.ffffb0fe@mx.google.com>
	<20080205155558.GA23145@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Glenn Griffin <ggriffin.kernel@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758460AbYBEPsT@vger.kernel.org>
In-Reply-To: <20080205155558.GA23145@one.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Syncookies are discouraged these days. They disable too many 
> valuable TCP features (window scaling, SACK) and even without them 
> the kernel is usually strong enough to defend against syn floods
> and systems have much more memory than they used to be.

Somewhat untrue. Network speeds have risen dramatically, the number of
appliances running Linux that are not PC class means memory has fallen
not risen and CPU has been pretty level.

> So I don't think it makes much sense to add more code to it, sorry.

I think it makes a lot of sense - providing it defaults off for the PC
world where as you say its use is limited.

Alan
