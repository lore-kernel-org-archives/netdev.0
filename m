From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Re: Problem with tun driver
Date: Thu, 16 Sep 2010 15:23:39 +0200
Message-ID: <AANLkTimB_PDr2RNWzd93QeAca5PE48hkzEHuM-Z80wTj@mail.gmail.com>
References: <AANLkTinzLJia4WV-GUse0sX=3Ht8DrD-vVd3YkxUE8xO@mail.gmail.com>
	<m1iq256d73.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Alina <aquereilhac@gmail.com>,
	Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60083 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517Ab0IPNXl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Sep 2010 09:23:41 -0400
Received: by iwn5 with SMTP id 5so1079563iwn.19
        for <netdev@vger.kernel.org>; Thu, 16 Sep 2010 06:23:41 -0700 (PDT)
In-Reply-To: <m1iq256d73.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Sep 16, 2010 at 15:16, Eric W. Biederman <ebiederm@xmission.com=
> wrote:

> Is it possible all of the processes in the network namespace you have
> passed the tun dev into are dying, and thus destroying the network
> namespace the tun dev is in?

I thought that might be the case, but no, I still have a process
there, and from that I spawn an "ip link" that shows me that the tap
device still exists and it is up.

> It sounds like you are dealing with the network namespace death case,
> or that someone is closing your filedescriptor on you.

I also checked that, but no, nobody is closing it... To make things
more strange, this happens to me only when communicating with my slave
processes by a ssh to localhost (the filedescriptor is passed using
SCM_RIGHTS), but not when I fork directly, so at this point a timing
issue seems to be the only explanation. But it still does not make
sense, as some traffic gets exchanged correctly.

Thanks for your time.
--=20
Mart=EDn Ferrari
