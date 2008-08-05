From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: thousands of classes, e1000 TX unit hang
Date: Tue, 5 Aug 2008 17:07:25 +0300
Message-ID: <200808051707.25601.denys@visp.net.lb>
References: <20080805110453.GA6541@ff.dom.local> <200808051413.58795.denys@visp.net.lb> <20080805122340.GB6541@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:51983 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837AbYHEOIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 10:08:12 -0400
In-Reply-To: <20080805122340.GB6541@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 05 August 2008, Jarek Poplawski wrote:
> reported often to the list (I remember once). Some workaround could be
> probably deleting individual classes (and filters) to give away a lock
> and soft interrupts for a while), before deleting the root, but I
> didn't test this. 
Btw even if i optimize my scripts, still when ppp interface going down and 
disappearing - all classes will be deleted, and system locked up for short 
time (with all related TX hang, packetloss and etc).
