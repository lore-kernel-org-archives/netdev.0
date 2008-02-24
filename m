From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [Bugme-new] [Bug 10061] New: Hang in md5_resync
Date: Sun, 24 Feb 2008 01:32:38 +0100
Message-ID: <20080224003238.GA4025@uio.no>
References: <bug-10061-10286@http.bugzilla.kernel.org/> <20080221170737.94ad17cb.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([129.241.93.19]:53965 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbYBXRmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2008 12:42:32 -0500
Content-Disposition: inline
In-Reply-To: <20080221170737.94ad17cb.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2008 at 05:07:37PM -0800, Andrew Morton wrote:
>> Downgraded to 2.6.23 again, seems to work fine. Will try 2.6.24.2 shortly.
> This looks like a networking regression, not a RAID regression.
> 
> We did have a big locking bug in netlink in 2.6.25-rc2, although your trace
> doesn't appear to point at that particular bug.
> 
> It would be good if you could test the latest Linux snapshot please, see if
> we've already fixed this, thanks.

The latest git snapshot seems to fix it; at least it's up again now (after an
age-long fsck), with no crash yet (it crashed very early on with 2.6.25-rc2).

/* Steinar */
-- 
Homepage: http://www.sesse.net/
