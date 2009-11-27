From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Sat, 28 Nov 2009 00:30:16 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0911280029040.11977@melkinpaasi.cs.helsinki.fi>
References: <20091127223545.2a752429@houba> <20091127232257.1c13ccde@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696230645-1007352497-1259361016=:11977"
Cc: Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:54128 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbZK0WaK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 17:30:10 -0500
In-Reply-To: <20091127232257.1c13ccde@houba>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696230645-1007352497-1259361016=:11977
Content-Type: TEXT/PLAIN; charset=utf-8
Content-Transfer-Encoding: 8BIT

On Fri, 27 Nov 2009, Frederic Leroy wrote:

> Le Fri, 27 Nov 2009 22:35:45 +0100,
> Frederic Leroy <fredo@starox.org> a écrit :
> > openssh versions : 
> > 
> > houba tmp # equery l openssh
> > [ Searching for package 'openssh' in all categories among: ]
> >  * installed packages
> > [I--] [  ] net-misc/openssh-5.2_p1-r3 (0)
> > 
> > fredo@sg:~$ dpkg -l | grep ssh
> > ii  libssh2-1                         0.18-1                    SSH2
> > client-side library ii  openssh-blacklist
> > 0.4.1                     list of default blacklisted OpenSSH RSA and
> > ii  openssh-client                    1:5.1p1-5
> > secure shell client, an rlogin/rsh/rcp repla ii
> > openssh-server                    1:5.1p1-5                 secure
> > shell server, an rshd replacement ii
> > ssh                               1:5.1p1-5                 secure
> > shell client and server (metapackage)
> > 
> > I will downgrade gentoo ssh and give another try ...
> 
> Argh !!! 
> 
> I emerged openssh-5.1_p1-r2 on houba.
> Restarted ssh server (/etc/init.d/sshd restart)
> Log on sg and make a scp as usual. 
> It worked fine.
> Make a second copy, and It worked fine also.
> 
> Then, I emerged openssh-5.2_p1-r3 on houba, restarted sshd, make three
> big copies ... and finally it worked fine. 
> 
> The bug mysteriously escaped from the dungeon !

...Anyway, I'll probably try to reproduce tomorrow myself based on the 
patterns I see in your logs.

-- 
 i.
---696230645-1007352497-1259361016=:11977--
