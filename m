From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: revert config space change
Date: Sun, 24 Jan 2010 22:36:40 -0800 (PST)
Message-ID: <20100124.223640.119299590.davem@davemloft.net>
References: <20100119193745.GA5797@x61.home>
	<201001242135.29309.rjw@sisk.pl>
	<20100124204606.2760d34e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rjw@sisk.pl, tino.keitel@gmx.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752588Ab0AYGgb@vger.kernel.org>
In-Reply-To: <20100124204606.2760d34e@nehalam>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Sun, 24 Jan 2010 20:46:06 -0800

> Obviously, this register had some other impact that is causing
> the regression.  Either it is masking some other access or needs
> to be reset in some path.
> 
> Either, way it is best to just revert the change for 2.6.33
> 
> 
> This reverts commit 166a0fd4c788ec7f10ca8194ec6d526afa12db75.

I'll apply this, thanks Stephen.
