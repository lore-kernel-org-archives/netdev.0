From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 14:02:49 -0700
Message-ID: <20060815140249.15472a82@dxpl.pdx.osdl.net>
References: <20060815194856.GA3869@nostromo.devel.redhat.com>
	<Pine.CYG.4.58.0608151331220.3272@mawilli1-desk2.amr.corp.intel.com>
	<20060815204555.GB4434@nostromo.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39835 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750712AbWHOVGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 17:06:12 -0400
To: Bill Nottingham <notting@redhat.com>
In-Reply-To: <20060815204555.GB4434@nostromo.devel.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 15 Aug 2006 16:45:55 -0400
Bill Nottingham <notting@redhat.com> wrote:

> Mitch Williams (mitch.a.williams@intel.com) said: 
> > Are spaces allowed in interface names anyway?  I can't believe that
> > bonding is the only area affected by this.
> 
> They're certainly allowed, and the sysfs directory structure, files,
> etc. handle it ok. Userspace tends to break in a variety of ways.
> 
> I believe the only invalid character in an interface name is '/'.
> 

The names "." and ".." are also verboten.
Names with : in them are for IP aliases.
