From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] Backward compatibility and WAN netdev configuration
Date: Wed, 1 Feb 2006 10:39:31 -0800
Message-ID: <20060201103931.08ad581d@dxpl.pdx.osdl.net>
References: <m3psm7tksr.fsf@defiant.localdomain>
	<20060201144917.GA7644@wonderland.linux.it>
	<m3r76n3p4k.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: md@Linux.IT (Marco d'Itri), netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422868AbWBASjk@vger.kernel.org>
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3r76n3p4k.fsf@defiant.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 01 Feb 2006 19:33:47 +0100
Krzysztof Halasa <khc@pm.waw.pl> wrote:

> md@Linux.IT (Marco d'Itri) writes:
> 
> > Why you cannot support autoloading the modules when a specific protocol
> > is needed?
> 
> I probably could but it would complicate things a bit - currently only
> the protocol module knows about existence of its protocol.
> 
> I will look at it, though. Thanks.

The modern way is to not have any entries in modprobe.conf, and do all
the module loading via kernel module_aliases. Modprobe.conf is then
reserved for handling workarounds for special cases
-- 
Stephen Hemminger <shemminger@osdl.org>
OSDL http://developer.osdl.org/~shemminger
