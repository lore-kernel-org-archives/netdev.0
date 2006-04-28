From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 22/32] rt2x00: Allocate ring structures in single array
Date: Fri, 28 Apr 2006 16:30:55 +0200
Message-ID: <20060428163055.0656bc08@griffin.suse.cz>
References: <200604280003.14287.IvDoorn@gmail.com>
	<20060428125201.4f20ece2@griffin.suse.cz>
	<200604281625.13165.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41389 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965208AbWD1Oa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 10:30:59 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200604281625.13165.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2006 16:25:09 +0200, Ivo van Doorn wrote:
> I am not really fan on such messages. But when the control->queue is indeed
> invalid, it is a serious bug. Perhaps a BUG() should be used as well?
> If so, I'll put it into a new patch along with the fixes below.

BUG() is not a good idea, this is not critical enough to panic the kernel.

-- 
Jiri Benc
SUSE Labs
