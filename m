From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [patch] workaround zd1201 interference problem
Date: Fri, 09 Jun 2006 22:49:04 +0100
Message-ID: <4489ECD0.1030908@gentoo.org>
References: <20060607140045.GB1936@elf.ucw.cz> <20060607160828.0045e7f5@griffin.suse.cz> <20060607141536.GD1936@elf.ucw.cz> <4486FD2F.8040205@gentoo.org> <20060608070525.GE3688@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, linville@tuxdriver.com,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta08-winn.ispmail.ntl.com ([81.103.221.48]:28846 "EHLO
	mtaout02-winn.ispmail.ntl.com") by vger.kernel.org with ESMTP
	id S1030537AbWFIVsA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 17:48:00 -0400
To: Pavel Machek <pavel@suse.cz>
In-Reply-To: <20060608070525.GE3688@elf.ucw.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Machek wrote:
> if you plug zd1201 into USB, it starts jamming radio,
> immediately. Enable/disable, or iwlist wlan0 scan, or basically any
> operation unjams the radio. This patch works it around:

Can we be any more specific?

What is the interference - is it transmitting random packets, or just 
emitting a magical cloud of invisible anti-wifi?

At which precise point does the interference start? Does it happen even 
without the driver loaded?

Which operation is the one which stops the interference, the enable or 
the disable?

Does this happen on every plug in, or just sometimes? Is it affected by 
usage patterns such as having the device plugged in throughout boot, 
reloading the module, etc?

Thanks,
Daniel

