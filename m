From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 3 Oct 2007 17:22:35 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710031709450.27745@kivilampi-30.cs.helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
 <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi>
 <47038FAB.9020106@free.fr> <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi>
 <4703A1BB.1040006@free.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-1677262667-1191421355=:27745"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:55753 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754811AbXJCOWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 10:22:37 -0400
In-Reply-To: <4703A1BB.1040006@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-1677262667-1191421355=:27745
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 3 Oct 2007, Cedric Le Goater wrote:

> Ilpo Järvinen wrote:
> > 
> > Ah, that's path 1) then... Since you seem to have enough time, I would say 
> > that the path 1 is good as well and bugs unrelated to the fix will show up 
> > there too...
> 
> arg. yes. sorry for the confusion.
> 
> > I should have stated it explicitly that with path 2 those 3 patches should 
> > not be applied because the aim is not a fix but reproducal. Path 2 was 
> > intentionally left without the potentional fix as then nice backtrace 
> > informs when we can stop trying (which would hopefully occurred 
> > pretty soon) :-).  But lets discard that path 2...
> 
> I have 2 spare nodes so i'll run both. 1) is on already without any issues
> i'm just compiling 2)

Thanks a lot. :-)

> I usually work on -mm, so what would be interesting for me is to have what you 
> need in net-2.6.24 which is getting pulled in -mm by andrew. then, if 
> you need an extra patch for verbosity, that's fine, i'll include it in 
> my usual patchset.

Ah, I'm sorry about the subject and the extra work it caused, it was 
meant for DaveM only, didn't realize at that time it would be 
meaningful to you as well, thus couldn't warn you back then... Testing on 
top of mm would be (/ have been) fine as well... From my point of view 
both mm and net-2.6.24 are pretty much the same (I even verified that 
those patches apply fine on top of rc8-mm2 since I thought that you might 
want to use that one).

-- 
 i.
---696243703-1677262667-1191421355=:27745--
