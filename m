From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 2/3] tuntap: allow overriding ethtool driver
 info
Date: Thu, 25 Jul 2013 22:36:22 +0100
Message-ID: <1374788182.3058.32.camel@bwh-desktop.uk.level5networks.com>
References: <20130724161156.4a8cf02b@nehalam.linuxnetplumber.net>
	 <20130724161325.38404ed3@nehalam.linuxnetplumber.net>
	 <1374709687.1732.46.camel@bwh-desktop.uk.level5networks.com>
	 <20130724171617.53a48d24@nehalam.linuxnetplumber.net>
	 <1374787157.3058.28.camel@bwh-desktop.uk.level5networks.com>
	 <20130725143206.03f4975a@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Helmut Grohne <h.grohne@cygnusnetworks.de>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17628 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325Ab3GYVg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 17:36:26 -0400
In-Reply-To: <20130725143206.03f4975a@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-25 at 14:32 -0700, Stephen Hemminger wrote:
> On Thu, 25 Jul 2013 22:19:17 +0100
> Ben Hutchings <bhutchings@solarflare.com> wrote:
> 
> > On Wed, 2013-07-24 at 17:16 -0700, Stephen Hemminger wrote:
> > > On Thu, 25 Jul 2013 00:48:07 +0100
> > > Ben Hutchings <bhutchings@solarflare.com> wrote:
> > > 
> > > > On Wed, 2013-07-24 at 16:13 -0700, Stephen Hemminger wrote:
> > > > > This patch adds new ioctl to allow setting the ethtool information
> > > > > returned by the TUN device. This is useful when using tun device as a surrogate
> > > > > for hardware or other software emulation.
> > > > 
> > > > I don't like this idea.  Which tools are you trying to fool?  How does
> > > > this work when you don't implement any driver-specific behaviour (e.g.
> > > > SIOCDEVPRIVATE) they expect?
> > > 
> > > We use surrogate interfaces in user mode application and want to
> > > display different information for these than the normal TUN device.
> > 
> > What is the problem that can't be solved purely in userland?
> > 
> > Ben.
> > 
> 
> There applications (like SNMP) that use ethtool info.

Huh, I never expected they would record the driver and version.  So you
want them to report the userland software name and version?  I can sort
of see how this might be useful as part of a test harness, but I would
hate to see this get used in production.  Users ought to be able to
trust that 'ethtool -i' shows them the kernel driver information.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
