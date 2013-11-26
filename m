From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: r8169 Wake on Lan
Date: Tue, 26 Nov 2013 20:36:17 +0000
Message-ID: <1385498177.1586.67.camel@bwh-desktop.uk.level5networks.com>
References: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Pablo Cholaky <mrwaltercool@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:12952 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752003Ab3KZUgW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Nov 2013 15:36:22 -0500
In-Reply-To: <CAEv3EXFiUnfkBCiedjXUzc6MXBnP2vqNx4R3739642dGYazTwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-11-26 at 14:23 -0300, Pablo Cholaky wrote:
> Hi there:
> 
> I have a HP ENVY laptop with this RealTek, and my laptop don't have a
> BIOS option to disable WOL. I'm currently using a script on start and
> shutdown to disable WOL, but could you guys make a module param to
> enable/disable WOL?
[...]

Module parameters are a terrible configuration interface, particularly
for settings that really apply to individual devices.

Most distributions provide a way to run ethtool when configuring an
interface; see
<http://sources.debian.net/src/ethtool/1:3.11-1/debian/README.Debian>
and look for ETHTOOL_OPTS in
<https://access.redhat.com/site/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Deployment_Guide/s1-networkscripts-interfaces.html>

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
