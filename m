From: Alessandro Zummo <alessandro.zummo@towertech.it>
Subject: Re: [RFC] [PATCH 1/2] Driver to remember ethernet MAC values:
 maclist
Date: Mon, 20 Feb 2006 03:01:46 +0100
Message-ID: <20060220030146.11f418dc@inspiron>
References: <20060220010113.GA19309@deprecation.cyrius.com>
	<20060220014735.GD4971@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Martin Michlmayr <tbm@cyrius.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, John Bowler <jbowler@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932564AbWBTCCK@vger.kernel.org>
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20060220014735.GD4971@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 20 Feb 2006 02:47:35 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> > Some Ethernet hardware implementations have no built-in storage for
> > allocated MAC values - an example is the Intel IXP420 chip which has
> > support for Ethernet but no defined way of storing allocated MAC values.
> > With such hardware different board level implementations store the
> > allocated MAC (or MACs) in different ways.  Rather than put board level
> > c
> Silly question:
> 
> Why can't this be implemented in user space using the SIOCSIFHWADDR 
> ioctl?

 Because sometimes you need to have networking available
 well before userspace.

 (netconsole, root over nfs, ...)

-- 

 Best regards,

 Alessandro Zummo,
  Tower Technologies - Turin, Italy

  http://www.towertech.it
