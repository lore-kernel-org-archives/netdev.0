From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: netem: Gilbert, Simple Gilbert, Bernouli loss model broken
Date: Thu, 22 Dec 2011 17:10:23 -0800
Message-ID: <20111222171023.1c343e6b@nehalam.linuxnetplumber.net>
References: <CAFXUZ_G7oAT9v1B4NNm5c2nxUpU_-zXNV47XzcyKNKgsDLjQzA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Marcus Wermuth <marcus.wermuth@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:45489 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854Ab1LWBK0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Dec 2011 20:10:26 -0500
In-Reply-To: <CAFXUZ_G7oAT9v1B4NNm5c2nxUpU_-zXNV47XzcyKNKgsDLjQzA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Nov 2011 12:40:29 +0100
Marcus Wermuth <marcus.wermuth@gmail.com> wrote:

> Hey,
> 
> I wanted to try the netem extension to setup a loss via Gilbert,
> Simple Gilbert, Bernouli loss model[1]. Kernel support is included
> since several releases. But configuration as demonstrated in [1] does
> not work at all. It seems that the userspace part in iproute is
> missing, the original patch from the authors does not work.
> 
> Does anybody know about that?
> 
> Bye, Marcus
> 
> (I'm not subscribed to netdev-list)
> 
> [1] http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG


I just wrote, tested and support for the loss model parameters
in iproute. Check the latest checkin in the git repo. Also the man
page has been fixed to reflect the implemented options.
