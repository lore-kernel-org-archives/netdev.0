From: Jiri Slaby <jirislaby@gmail.com>
Subject: /proc/net/ bad hard links count [Was: 2.6.23-rc8-mm2]
Date: Fri, 28 Sep 2007 18:30:08 +0200
Message-ID: <46FD2C10.8050105@gmail.com>
References: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Eric Biederman <ebiederm@xmission.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:52763 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbXI1QaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:30:13 -0400
Received: by ug-out-1314.google.com with SMTP id z38so1510158ugc
        for <netdev@vger.kernel.org>; Fri, 28 Sep 2007 09:30:11 -0700 (PDT)
In-Reply-To: <20070927022220.c76a7a6e.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/27/2007 11:22 AM, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.23-rc8/2.6.23-rc8-mm2/

# find /proc >/dev/null
find: WARNING: Hard link count is wrong for /proc/net: this may be a bug in your
filesystem driver.  Automatically turning on find's -noleaf option.  Earlier
results may have failed to include directories that should have been searched.
# stat net
  File: `net'
  Size: 0               Blocks: 0          IO Block: 1024   directory
Device: 3h/3d   Inode: 4026531864  Links: 2
Access: (0555/dr-xr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2007-09-28 18:21:24.651209759 +0200
Modify: 2007-09-28 18:21:24.651209759 +0200
Change: 2007-09-28 18:21:24.651209759 +0200
# stat net/
  File: `net/'
  Size: 0               Blocks: 0          IO Block: 1024   directory
Device: 3h/3d   Inode: 4026531909  Links: 4
Access: (0555/dr-xr-xr-x)  Uid: (    0/    root)   Gid: (    0/    root)
Access: 2007-09-28 18:26:48.813048220 +0200
Modify: 2007-09-28 18:26:48.813048220 +0200
Change: 2007-09-28 18:26:48.813048220 +0200

hmm, this is some kind of weirdness :)

regards,
-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University

-- 
Jiri Slaby (jirislaby@gmail.com)
Faculty of Informatics, Masaryk University
