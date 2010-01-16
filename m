From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v5] rps: Receive Packet Steering
Date: Sat, 16 Jan 2010 02:11:33 +0000
Message-ID: <1263607893.17815.114.camel@localhost>
References: <alpine.DEB.1.00.1001141353140.19018@pokey.mtv.corp.google.com>
	 <20100114145633.4c2d4ac6@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:41696 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758695Ab0APCLi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 21:11:38 -0500
In-Reply-To: <20100114145633.4c2d4ac6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-01-14 at 14:56 -0800, Stephen Hemminger wrote:
> On Thu, 14 Jan 2010 13:56:23 -0800 (PST)
> Tom Herbert <therbert@google.com> wrote:
[...]
> > The CPU masks is set on a per device basis in the sysfs variable
> > /sys/class/net/<device>/rps_cpus.  This is a set of canonical bit maps for
> > each NAPI nstance of the device.  For example:
> > 
> > echo "0b 0b0 0b00 0b000" > /sys/class/net/eth0/rps_cpus
> 
> Why not make a kobject out of cpus which would add subdirectory.
> This would keep interface consistent with the one value per file
> semantic of sysfs.

Do you mean a kobject per NAPI context, each initially with a rps_cpus
attribute holding a CPU mask, or a kobject per CPU, each with an
attribute specifying which NAPI contexts it does work for?  (Personally
I'd favour the first.)

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

