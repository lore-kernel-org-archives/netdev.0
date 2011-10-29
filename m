From: Jiri Slaby <jslaby@suse.cz>
Subject: Broken link in /sys/class/net/ [was: [GIT] Networking]
Date: Sun, 30 Oct 2011 01:03:30 +0200
Message-ID: <4EAC8642.3050309@suse.cz>
References: <20111025.063206.2273357152859701628.davem@davemloft.net> <CA+55aFw1GVvszqoC_f0RAvG5t1xj0CSYLhLU=y0gQ+_54Gsomw@mail.gmail.com> <20111025131315.GA1899@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Mikulas Patocka <mpatocka@redhat.com>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jiri Slaby <jirislaby@gmail.com>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:50623 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755272Ab1J2XDf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2011 19:03:35 -0400
In-Reply-To: <20111025131315.GA1899@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/2011 03:13 PM, Greg KH wrote:
> On Tue, Oct 25, 2011 at 01:46:11PM +0200, Linus Torvalds wrote:
>> Anyway, after that rant about really bad practices, let me say that I
>> did fix up the conflict and I think it's right. But I won't guarantee
>> it, so please check the changes to fs/sysfs/dir.c.
> 
> I think it looks ok, I've booted the merge result, and am typing and
> sending this from the new kernel, and it hasn't crashed yet :)

Hi, maybe this was not caused by the merge, but the patch[1] causes this
mess in /sys/class/net/ for me:
l????????? ? ?    ?    ?             ? eth1

This happens after one renames a net device -- the new name is eth1 here.

[1] 4f72c0cab40 (sysfs: use rb-tree for name lookups)

regards,
-- 
js
suse labs
