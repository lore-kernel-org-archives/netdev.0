From: "Daniel Bonekeeper" <thehazard@gmail.com>
Subject: Sockets inside the kernel or userspace ?
Date: Fri, 30 Jun 2006 03:32:28 -0400
Message-ID: <e1e1d5f40606300032t7162e165qaa915658e0a71386@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:45588 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S1751239AbWF3Hc3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 03:32:29 -0400
Received: by py-out-1112.google.com with SMTP id t32so557311pyc
        for <netdev@vger.kernel.org>; Fri, 30 Jun 2006 00:32:28 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Let's suppose that I'm writing a experimental distributed filesystem
that needs to open a TCP socket to another machines on the LAN, keep a
pool of connections and be always aware of new data arriving (like a
userspace select()). What's the best approach to implement this ? Is
it better to keep all the TCP socket stuff in userspace and use an
interface like netlink to talk with it ? Or, since we're talking about
a filesystem (where performance is a must), is it better to keep it in
kernel mode ?

Thanks!

--=20
"Quanto mais conhe=E7o os homens, mais gosto dos meus cavalos"
- Jo=E3o Figueiredo, former Brazilian president.
