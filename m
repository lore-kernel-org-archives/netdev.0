From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: bonding driver - how to recognize the active slave
Date: Fri, 21 Dec 2012 12:34:33 +0100
Message-ID: <20121221113433.GA2040@minipsycho.orion>
References: <BA0B6857ABCA474FB07F0DA6F50A3077918B2450@MTRDAG01.mtl.com>
 <1356038370.21834.3315.camel@edumazet-glaptop>
 <CAJZOPZLOj2QCWN75hAsQnmB=YiSGRhdhzf4ODhAD-QoU+Y0ZGg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <erdnetdev@gmail.com>,
	Erez Shitrit <erezsh@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f47.google.com ([74.125.83.47]:51369 "EHLO
	mail-ee0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729Ab2LULeh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2012 06:34:37 -0500
Received: by mail-ee0-f47.google.com with SMTP id e51so2284977eek.6
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2012 03:34:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CAJZOPZLOj2QCWN75hAsQnmB=YiSGRhdhzf4ODhAD-QoU+Y0ZGg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 20, 2012 at 11:21:00PM CET, or.gerlitz@gmail.com wrote:
>On Thu, Dec 20, 2012 at 11:19 PM, Eric Dumazet <erdnetdev@gmail.com> wrote:
>> cat /sys/class/net/bond0/bonding/active_slave
>
>sure, I think Erez would like to know that from within a network
>device kernel code, e.g maybe register to netdev kernel events and on
>the event of bonding fail-over identify the active slave for
>active-backup mode, etc.

I wonder why device should care of such thing? Would it behave
differently?

>
>Or.
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
