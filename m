From: Jiri Kosina <jkosina@suse.cz>
Subject: Re: Aw: Re: [PATCH 0/5] HID: roccat: Achieve userspace notification
 on sysfs attribute creation
Date: Thu, 9 Dec 2010 14:52:24 +0100 (CET)
Message-ID: <alpine.LNX.2.00.1012091451400.508@pobox.suse.cz>
References: <alpine.LNX.2.00.1012091430130.508@pobox.suse.cz> <1290801444.18750.161.camel@neuromancer> <2069123096.22885.1291902246397.JavaMail.ngmail@webmail07.arcor-online.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: rdunlap@xenotime.net, gregkh@suse.de, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-input@vger.kernel.org,
	netdev@vger.kernel.org
To: Stefan Achatz <erazor_de@users.sourceforge.net>
Return-path: <linux-input-owner@vger.kernel.org>
In-Reply-To: <2069123096.22885.1291902246397.JavaMail.ngmail@webmail07.arcor-online.net>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Dec 2010, Stefan Achatz wrote:

> > I have applied the series, and removed the #pragma pack ugliness. Thanks,
> 

> Hello Jiri,
> Using my patch replacing the #pragma pack with the __packed macro would 
> have saved you some time: https://lkml.org/lkml/2010/11/27/14

Ah, missed that. Never mind.

> Just for the future: Whats better using the verbose version 
> __attribute__ ((__packed__)) or the macro __packed as I did?

I don't think I really care deeply here.

For some rationale why these shortcuts exist, please see commit 
82ddcb0405704.

-- 
Jiri Kosina
SUSE Labs, Novell Inc.
