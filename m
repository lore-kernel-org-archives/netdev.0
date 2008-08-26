From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: loaded router, excessive getnstimeofday in oprofile
Date: Tue, 26 Aug 2008 13:49:09 +0300
Message-ID: <200808261349.09820.denys@visp.net.lb>
References: <20080826095126.GA2609@ff.dom.local> <200808261329.53741.denys@visp.net.lb> <20080826104717.GB2609@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay2.globalproof.net ([194.146.153.25]:56550 "EHLO
	relay2.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753606AbYHZKuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 06:50:37 -0400
In-Reply-To: <20080826104717.GB2609@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 26 August 2008, Jarek Poplawski wrote:
> The question is if you really need so exact shaping at a cost of
> higher system load.
Thats maybe another reason to have your patch in mainline :-)
I will try it today with this case, if it will help.

Maybe it can be optional, and enabled via kernel parameter and /sys , so it 
can be useful in case of crashes when TSC used and when timer is too slow.
Because it is not so useful just to disable hrtimers completely, if you need 
them for some other task...

