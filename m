From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Namespaces and devices
Date: Fri, 21 May 2010 18:27:58 +0200
Message-ID: <AANLkTimN8IYQBiot2iBB6XV8dtTGRnHQQ6lKLag5plEm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:38261 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756614Ab0EUQ17 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 May 2010 12:27:59 -0400
Received: by vws9 with SMTP id 9so973615vws.19
        for <netdev@vger.kernel.org>; Fri, 21 May 2010 09:27:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Sorry if this is a dumb question, but I couldn't find any
documentation that matches the current behaviour... So I don't know if
what I see is what is intended, or if it's a bug.

I would like to know what is the exact behaviour re. devices when a
netns is destroyed, and which kind of devices can be moved.

According to http://lxc.sourceforge.net/network/configuration.php,
devices assigned to a netns should move to the main netns when the
former is destroyed. What I see is that the devices are deleted, at
least for veth and dummy devices. I also see a bug I previously
reported that caused an oops in some cases.

Also, I have read somewhere (now I cannot find it) that supposedly, I
should be able to move real devices to a netns, but I always get
Invalid argument errors.

Thanks.

--=20
Mart=EDn Ferrari
