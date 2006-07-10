From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211 sysfs
Date: Mon, 10 Jul 2006 17:27:02 +0200
Message-ID: <20060710172702.288680e9@griffin.suse.cz>
References: <a32f33a40607080505wd3c9200sdf50ff814fd5afb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:60322 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964839AbWGJP1E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2006 11:27:04 -0400
To: "Ivo Van Doorn" <ivdoorn@gmail.com>
In-Reply-To: <a32f33a40607080505wd3c9200sdf50ff814fd5afb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 8 Jul 2006 14:05:08 +0200, Ivo Van Doorn wrote:
> Since I didn't want to loose any tested because of the new field in
> the net_device structure,
> I have used the base_addr field instead and used the following access functions:

This will horribly fail when you send something to master device
(wmaster0) directly. For example, having ipv6 enabled is enough to
produce some funny Oopses.

> kernel BUG at fs/sysfs/symlink.c:88!
> invalid opcode: 0000 [#1]
> SMP

d80211 stack is not SMP safe yet. Is this reproducible on non-SMP
non-preemptible kernel without your base_addr patches?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
