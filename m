From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [2.6 patch] drivers/net/ixgb/: possible cleanups
Date: Sat, 07 May 2005 15:09:01 +0200
Message-ID: <1115471341.6388.41.camel@laptopd505.fenrus.org>
References: <20050506211834.GM3590@stusta.de>
	 <5fc59ff3050506153523cd12dd@mail.gmail.com>
	 <1115468645.6388.37.camel@laptopd505.fenrus.org>
	 <20050507123814.GJ3590@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>,
	ayyappan.veeraiyan@intel.com, ganesh.venkatesan@intel.com,
	john.ronciak@intel.com, jgarzik@pobox.com, netdev@oss.sgi.com,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262909AbVEGNJS@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20050507123814.GJ3590@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> I'm not sure whether Ganesh was really talking about license issues, or 
> whether the problem is that my patch #if 0's away code they use in other 
> non-GPL'ed drivers.

fair point, the solution for the later could be to use #ifndef __linux__
or something instead of #if 0
