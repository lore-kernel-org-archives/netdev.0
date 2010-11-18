From: Bill Nottingham <notting@redhat.com>
Subject: Re: extended netdevice naming proposal
Date: Wed, 17 Nov 2010 21:10:40 -0500
Message-ID: <20101118021039.GA18707@nostromo.devel.redhat.com>
References: <20101117220659.GA12177@auslistsprd01.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-hotplug@vger.kernel.org, netdev@vger.kernel.org,
	narendra_k@dell.com, jcm@redhat.com
To: Matt Domsch <Matt_Domsch@dell.com>
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20101117220659.GA12177@auslistsprd01.us.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Matt Domsch (Matt_Domsch@dell.com) said: 
> (location)(slot)#(port)/(instance).(vlan)

AIUI, the kernel explicitly rejects '/' in the name (for fairly obvious
sysfs reasons.) So you'd at least need a different delimiter. There may
also be potential confusion with pci01#03:02.0001 with someone thinking
that's bus/dev/fn, if we're being really petty.

Bill
