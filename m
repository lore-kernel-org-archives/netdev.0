From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: deadlocks if use htb
Date: Wed, 14 Jan 2009 14:41:34 +0200
Message-ID: <200901141441.34257.denys@visp.net.lb>
References: <20081010090426.GA6054@ff.dom.local> <200901141417.58667.denys@visp.net.lb> <20090114123623.GA6117@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Chris Caputo <ccaputo@alt.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:58674 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950AbZANMlk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 07:41:40 -0500
In-Reply-To: <20090114123623.GA6117@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 January 2009 14:36:23 Jarek Poplawski wrote:
> On Wed, Jan 14, 2009 at 02:17:58PM +0200, Denys Fedoryschenko wrote:
> > I will try that patches too, when i got this message, after 3 minutes i
> > got crash of my router :-) after working around 17 hours :-(
> > There is 3 of them by the way, 2 fixes also.
> >
> > hrtimer: removing all ur callback modes
> > hrtimer: removing all ur callback modes, fix hotplug
> > hrtimer: removing all ur callback modes, fix
>
> Yes, it's a very nasty bug which, BTW you reported the first AFAIK,
> but I hope it's really gone with these patches.
>
If it is really fix, it must go to mainline ASAP.
Because really many people hitting this bug... and complaining, that "Linux 
with htb not stable".
But i think it is not just fix :-(
