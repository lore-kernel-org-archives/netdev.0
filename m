From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: Re: bonding driver - how to recognize the active slave
Date: Fri, 21 Dec 2012 00:21:00 +0200
Message-ID: <CAJZOPZLOj2QCWN75hAsQnmB=YiSGRhdhzf4ODhAD-QoU+Y0ZGg@mail.gmail.com>
References: <BA0B6857ABCA474FB07F0DA6F50A3077918B2450@MTRDAG01.mtl.com>
	<1356038370.21834.3315.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Erez Shitrit <erezsh@mellanox.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Eric Dumazet <erdnetdev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:64052 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751094Ab2LTW1f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 17:27:35 -0500
Received: by mail-qc0-f169.google.com with SMTP id t2so2209719qcq.0
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 14:27:34 -0800 (PST)
In-Reply-To: <1356038370.21834.3315.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 20, 2012 at 11:19 PM, Eric Dumazet <erdnetdev@gmail.com> wrote:
> cat /sys/class/net/bond0/bonding/active_slave

sure, I think Erez would like to know that from within a network
device kernel code, e.g maybe register to netdev kernel events and on
the event of bonding fail-over identify the active slave for
active-backup mode, etc.

Or.
