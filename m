From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: How to file a bug against iproute2?
Date: Tue, 16 Apr 2013 20:32:39 +0100
Message-ID: <1366140759.2645.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAAc8SH5MjWdcFbkmV5uJgUv7nr_PN8n99azV4ZKxL3EKJ9Vthg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Alex Stahl <testcore@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:28354 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935427Ab3DPTco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Apr 2013 15:32:44 -0400
In-Reply-To: <CAAc8SH5MjWdcFbkmV5uJgUv7nr_PN8n99azV4ZKxL3EKJ9Vthg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-16 at 12:05 -0700, Alex Stahl wrote:
> Hi Folks - Apologies in advance if this is the wrong forum for this...
> I'd like to file a bug against iproute2 related to a permissions
> issue, but can't find the bug tracker.

This list is the bug tracker.

[...]
> According to the arch wiki, if I'm in the 'network' group I should be
> able to manipulate interfaces:
> 
> https://wiki.archlinux.org/index.php/Groups#Group_list
[...]

That's talking about what groups should be used for access control by
daemons and in the filesystem.  As far as the kernel is concerned,
network configuration depends on the CAP_NET_ADMIN capability, not group
membership.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
