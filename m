From: Tobias Diedrich <ranma+kernel@tdiedrich.de>
Subject: Re: [PATCH 0/4] Fix forcedeth hibernate/wake-on-lan problems
Date: Sun, 25 May 2008 17:04:44 +0200
Message-ID: <20080525150444.GA29739@yamamaya.is-a-geek.org>
References: <20080518125715.GA19229@yamamaya.is-a-geek.org> <20080518150908.GA4606@yamamaya.is-a-geek.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yumi.tdiedrich.de ([85.10.210.183]:59754 "EHLO mx.tdiedrich.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853AbYEYPFS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 May 2008 11:05:18 -0400
Content-Disposition: inline
In-Reply-To: <20080518150908.GA4606@yamamaya.is-a-geek.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tobias Diedrich wrote:

> First Windoze:
> Windoze, Standby (equiv. to Linux 'mem' state):  WOL borked, resumes =
fine
> Windoze, Hibernate: WOL borked, resumes fine

I have to correct myself on this:
I ran the above test an a japanese version of Windows (where I have
some difficulty reading all the technical texts)
I've retested this on an english version of Windows and
found that I accidentally enabled one checkbox, which said:
"Only allow management stations to bring the computer out of standby"

If I disable that one, I can wakeup the machine without problems.

So my BIOS is not as borked as I thought and it should be possible
to wake up the machine even with platform.  Further debugging will
have to wait until at least next weekend though (maybe longer)...

--=20
Tobias						PGP: http://9ac7e0bc.uguu.de
=E3=81=93=E3=81=AE=E3=83=A1=E3=83=BC=E3=83=AB=E3=81=AF=E5=8D=81=E5=89=B2=
=E5=86=8D=E5=88=A9=E7=94=A8=E3=81=95=E3=82=8C=E3=81=9F=E3=83=93=E3=83=83=
=E3=83=88=E3=81=A7=E4=BD=9C=E3=82=89=E3=82=8C=E3=81=A6=E3=81=84=E3=81=BE=
=E3=81=99=E3=80=82
