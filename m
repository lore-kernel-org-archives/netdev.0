From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: How to enable Adaptive RX on
Date: Tue, 5 Feb 2013 19:54:25 +0000
Message-ID: <1360094065.2857.20.camel@bwh-desktop.uk.solarflarecom.com>
References: <CAJzooYfqO64TgrswgrpHw5VmzeO_XveGUDy7tPQ0s4+zsnKO0A@mail.gmail.com>
	 <1360092001.2857.3.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAJzooYfgPcpakMigNH8hk1OavzTe0SiHxpM=_6FL--Rm0HmfBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Dhanasekaran Anbalagan <bugcy013@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17844 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756073Ab3BETy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 14:54:28 -0500
In-Reply-To: <CAJzooYfgPcpakMigNH8hk1OavzTe0SiHxpM=_6FL--Rm0HmfBg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-02-05 at 14:23 -0500, Dhanasekaran Anbalagan wrote:
> Hi we have the following 
> 
> root@dvcl150:~# ethtool -i eth0 
> driver: igb
> version: 3.2.10-k
> firmware-version: 1.6-1
> bus-info: 0000:04:00.0
> supports-statistics: yes
> supports-test: yes
> supports-eeprom-access: yes
> supports-register-dump: yes

This driver doesn't support adaptive RX IRQ coalescing.  It should
report an error when you try to enable it, but currently just ignores
that setting.

Ben.


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
