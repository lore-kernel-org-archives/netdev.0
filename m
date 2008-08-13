From: ian_bruce@fastmail.fm
Subject: [BUG] problem with 3c905 on AMD64
Date: Wed, 13 Aug 2008 00:51:03 -0700
Message-ID: <20080813005103.c7348e24.ian_bruce@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport2-out.teksavvy.com ([206.248.154.182]:25540 "EHLO
	ironport2-out.teksavvy.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751117AbYHMHyT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 03:54:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hardware: i386 and amd64 boxes, both with 3c905 network cards, directly
connected with crossover ethernet cable.

Software: Linux 2.6.25/i686 and Linux 2.6.25/amd64, respectively, both
from Debian packages.

While copying files from the i386 to the amd64, I found that the
transfer rate was only 7Kbyte/s. This was the case with both FTP and
HTTP, so it didn't seem like a user-level problem.

Strangely, when I tried copying files not FROM the i386, but only
THROUGH it, as a router, the problem went away, and I got the much
higher transfer rate I would have expected from the upstream link on the
other side of the i386.

With a different network adapter (Atheros) in the amd64, the problem
went away entirely.

The results were the same with the amd64 running Linux 2.6.18, so it's
not an issue that's specific to a particular kernel version.

I conclude: since the problem was fixed by using a different network
adapter, with the same software configuration on both ends of the
connection, this is a kernel issue. However, since it only manifests
itself when the i386 is a connection endpoint, but not a router in the
network path, it's a problem with the IP network stack, rather than the
3c905 hardware driver itself. The IP stack must somehow interact
differently with this driver than with the one which did work.

Please CC me on any replies to this message, as I'm not subscribed to
the mailing list.


<ian_bruce(at)fastmail.fm>

