From: Bill Nottingham <notting@redhat.com>
Subject: Re: bonding: cannot remove certain named devices
Date: Tue, 15 Aug 2006 16:45:55 -0400
Message-ID: <20060815204555.GB4434@nostromo.devel.redhat.com>
References: <20060815194856.GA3869@nostromo.devel.redhat.com> <Pine.CYG.4.58.0608151331220.3272@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:30434 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750725AbWHOUqB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2006 16:46:01 -0400
To: Mitch Williams <mitch.a.williams@intel.com>
Content-Disposition: inline
In-Reply-To: <Pine.CYG.4.58.0608151331220.3272@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mitch Williams (mitch.a.williams@intel.com) said: 
> Are spaces allowed in interface names anyway?  I can't believe that
> bonding is the only area affected by this.

They're certainly allowed, and the sysfs directory structure, files,
etc. handle it ok. Userspace tends to break in a variety of ways.

I believe the only invalid character in an interface name is '/'.

Bill
