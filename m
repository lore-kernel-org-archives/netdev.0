From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: FYI: Etherleak
Date: Thu, 9 Jan 2003 21:08:08 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030110020808.GA18605@gtf.org>
References: <D71BEAC27500D51199DF0002B328BA8D4FBF2B@ivexs1.intruvert.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Yan-Fa Li <yan@intruvert.com>
Content-Disposition: inline
In-Reply-To: <D71BEAC27500D51199DF0002B328BA8D4FBF2B@ivexs1.intruvert.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Jan 09, 2003 at 05:49:47PM -0800, Yan-Fa Li wrote:
> An interesting report into frame-padding information leakage violations in
> ethernet drivers.  The authors use linux drivers in their examples.
> 
> http://www.atstake.com/research/advisories/2003/atstake_etherleak_report.pdf

Yes.  All of those drivers are for ancient and/or obscure hardware
except three:  rtl8139, epic100, and via-rhine.

There are fixes for those (and others) in testing right now, in fact :)
