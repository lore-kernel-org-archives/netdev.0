From: Dave Jones <davej@redhat.com>
Subject: latest -stable breaks Squid
Date: Wed, 3 May 2006 17:19:15 -0400
Message-ID: <20060503211915.GD27368@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Cc: stable@vger.kernel.org,
	"Andreas M. Kirchwitz" <fedora-list@list.zikzak.de>,
	Vassilios Kotoulas <fedoralist@kotoulas.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:14759 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751354AbWECVTW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 May 2006 17:19:22 -0400
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

So I pushed out an update for Fedora Core 5 users yesterday
that moved the kernel from 2.6.16.9 to 2.6.16.13.
I've since heard "My network performance is awful", and worse
yet, some apps seem broken as in the report below.

Anyone have any ideas ?

		Dave

-- 
http://www.codemonkey.org.uk

--fUYQa+Pmc3FrFX/N
Content-Type: message/rfc822
Content-Disposition: inline

Return-Path: <fedora-list-bounces@redhat.com>
X-Spam-Checker-Version: SpamAssassin 3.1.1 (2006-03-10) on
	nwo.kernelslacker.org
X-Spam-Level: 
X-Spam-Status: No, score=0.4 required=5.0 tests=BAYES_00,UNPARSEABLE_RELAY
	autolearn=ham version=3.1.1
Received: from 172.16.58.1 [172.16.58.1]
	by nwo.kernelslacker.org with IMAP (fetchmail-6.3.4)
	for <davej@localhost> (single-drop); Wed, 03 May 2006 08:53:58 -0400 (EDT)
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by devserv.devel.redhat.com (8.12.11/8.12.11) with ESMTP id k43Craw0007892;
	Wed, 3 May 2006 08:53:36 -0400
Received: from mx1.util.phx.redhat.com (mx1.util.phx.redhat.com [10.8.4.92])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id k43CraOj015462;
	Wed, 3 May 2006 08:53:36 -0400
Received: from hormel.redhat.com (hormel.util.phx.redhat.com [10.8.4.111])
	by mx1.util.phx.redhat.com (8.13.1/8.13.1) with ESMTP id k43CrVY9025550;
	Wed, 3 May 2006 08:53:31 -0400
Received: from listman.util.phx.redhat.com (listman.util.phx.redhat.com [10.8.4.110])
	by hormel.redhat.com (Postfix) with ESMTP
	id 9D4B4731DA; Wed,  3 May 2006 08:53:23 -0400 (EDT)
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by listman.util.phx.redhat.com (8.13.1/8.13.1) with ESMTP id
	k43CrKTH004111 for <fedora-list@listman.util.phx.redhat.com>;
	Wed, 3 May 2006 08:53:21 -0400
Received: from mx3.redhat.com (mx3.redhat.com [172.16.48.32])
	by int-mx1.corp.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k43CrKJ4015436
	for <fedora-list@redhat.com>; Wed, 3 May 2006 08:53:20 -0400
Received: from nautilus.zikzak.de (nautilus.zikzak.de [213.73.91.25])
	by mx3.redhat.com (8.13.1/8.13.1) with ESMTP id k43CrBhQ002653
	for <fedora-list@redhat.com>; Wed, 3 May 2006 08:53:12 -0400
Received: from localhost ([127.0.0.1]:38058 helo=nautilus.zikzak.de)
	by nautilus.zikzak.de with smtp (Exim 4.60)
	(envelope-from <fedora-list@list.zikzak.de>) id 1FbGqn-0006t9-Bw
	for fedora-list@redhat.com; Wed, 03 May 2006 14:53:05 +0200
Received: from news2mail by nautilus.zikzak.de; Wed, 03 May 2006 12:53:05 GMT
From: "Andreas M. Kirchwitz" <fedora-list@list.zikzak.de>
Date: Wed, 3 May 2006 12:53:04 +0000 (UTC)
Organization: Touched By The Hand Of God
Message-ID: <slrne5h9tg.or2.amk@nautilus.zikzak.de>
To: fedora-list@redhat.com
X-RedHat-Spam-Score: -2.82 
X-loop: fedora-list@redhat.com
Subject: Kernel 2.6.16-1.2107_FC5 breaks Squid
X-BeenThere: fedora-list@redhat.com
X-Mailman-Version: 2.1.5
Precedence: junk
Reply-To: For users of Fedora Core releases <fedora-list@redhat.com>
List-Id: For users of Fedora Core releases <fedora-list.redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/fedora-list>
List-Post: <mailto:fedora-list@redhat.com>
List-Help: <mailto:fedora-list-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/fedora-list>,
	<mailto:fedora-list-request@redhat.com?subject=subscribe>
Sender: fedora-list-bounces@redhat.com
Errors-To: fedora-list-bounces@redhat.com

Hi folks!

Just installed the new kernel 2.6.16-1.2107_FC5 (32-bit, i686),
and everything seems to work fine -- except Squid (not matter
if I use the one that ships with FC5 or my own).

No problem with small data objects (a few kilobytes).

   telnet localhost 3128
   GET http://www.kirchwitz.de/test.html HTTP/1.0

Large data objects won't work. According to ethereal, the data
is loaded successfully. And I also find the complete objects
in /var/spool/squid, but the data is not output to the application:

   telnet localhost 3128
   GET http://www.heise.de/ HTTP/1.0

After a few kilobytes, the stream suddenly stops. Sometimes,
Squid doesn't do any output at all, although the object is in
the cache.

With the previous kernel 2.6.16-1.2096_FC5 all is well.

What has changed in the kernel that makes Squid break so hardly?
Maybe other applications are affected as well. Don't know yet.
The error with squid was simply very obvious. ;-)

	Greetings, Andreas

-- 
fedora-list mailing list
fedora-list@redhat.com
To unsubscribe: https://www.redhat.com/mailman/listinfo/fedora-list

--fUYQa+Pmc3FrFX/N--
