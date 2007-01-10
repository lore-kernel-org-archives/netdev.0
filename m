From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: don't symlink empty default keys
Date: Wed, 10 Jan 2007 21:11:57 +0100
Message-ID: <20070110211157.5804f673@griffin.suse.cz>
References: <45A4183E.4010401@web.de>
	<20070110204029.014cc96d@griffin.suse.cz>
	<45A54708.30307@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:36327 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965077AbXAJUMB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:12:01 -0500
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <45A54708.30307@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Jan 2007 21:05:28 +0100, Jan Kiszka wrote:
> Hmm, is this required? Will sysfs_remove_link panic on non-existent
> nodes?

No, it won't.

> If yes or if it's considered better style,

I consider it a better style as it's more tolerant to possible changes
in sysfs_remove_link.

> are you OK with
> catching NULL in ieee80211_key_sysfs_remove_default and refactoring the
> existing tests along this way?

Yes.

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
