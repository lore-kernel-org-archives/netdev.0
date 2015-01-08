From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC net-next 0/3] devconf: New infrastructure for setting
 pre-load parameters for a module
Date: Thu, 8 Jan 2015 14:32:20 -0800
Message-ID: <20150108223220.GA23424@kroah.com>
References: <1420730220-20224-1-git-send-email-hadarh@mellanox.com>
 <20150108164618.GA11696@kroah.com>
 <54AEBA28.1030301@mellanox.com>
 <20150108174707.GA13218@kroah.com>
 <CAPcc5PivsUKr9Q3VN1NFn3xJiB339EdPV=DEiLie8d9QVgOmOg@mail.gmail.com>
 <20150108192513.GB1961@kroah.com>
 <CAPcc5PgyBh3Hn4_7kiche2VLFJRXGPUaBw1ycZgvXiR0TSToxw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	"shannon.nelson@intel.com" <shannon.nelson@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	"greearb@candelatech.com" <greearb@candelatech.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:45935 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932670AbbAHWcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2015 17:32:21 -0500
Content-Disposition: inline
In-Reply-To: <CAPcc5PgyBh3Hn4_7kiche2VLFJRXGPUaBw1ycZgvXiR0TSToxw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 09, 2015 at 12:28:21AM +0200, Amir Vadai wrote:
> On Thu, Jan 8, 2015 at 9:25 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> > On Thu, Jan 08, 2015 at 09:14:32PM +0200, Amir Vadai wrote:
> >> On Thu, Jan 8, 2015 at 7:47 PM, Greg KH <gregkh@linuxfoundation.org> wrote:
> >> > On Thu, Jan 08, 2015 at 07:11:04PM +0200, Amir Vadai wrote:
> >> >> On 1/8/2015 6:46 PM, Greg KH wrote:
> >> >> > On Thu, Jan 08, 2015 at 05:16:57PM +0200, Hadar Hen Zion wrote:
> >> >> >> Hi,
> >> >> >>
> >> >> >> When configuring a device at an early boot stage, most kernel drivers
> >> >> >> use module parameters (the parameters' settings can be determined in
> >> >> >> modprobe.d config files).
> >> >> >
> >> >> > Which is a bad idea, as you have learned :)
> 
> [...]
> 
> >
> > But you are talking about loading config info before the driver is
> > loaded, which goes backwards for how we automatically load modules when
> > the hardware is found.
> 
> I guess you're a busy man and getting tired of my nudges. And it is ok
> with us to make it a non-generic solution - so I won't bother you much
> more...
> I would like to understand the arguments here: Maybe there is a
> history that I missed - What are the arguments against having a config
> info before the driver is loaded? Assuming, that it will make the
> driver loading process simpler and faster.

How can you load any configuration before the module is loaded if your
module is loaded automatically during the initrd?

drivers are loaded on demand, when the hardware is found, don't force
people to configure things manually by running a tool before your module
is loaded, as that is not how the module load process works at all.

greg k-h
