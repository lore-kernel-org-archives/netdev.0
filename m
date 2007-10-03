From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 3 Oct 2007 16:19:03 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0710031554380.27745@kivilampi-30.cs.helsinki.fi>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
 <470383D4.9060307@free.fr> <Pine.LNX.4.64.0710031503220.27745@kivilampi-30.cs.helsinki.fi>
 <47038FAB.9020106@free.fr>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696243703-318885690-1191417543=:27745"
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <legoater@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:44407 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753769AbXJCNTG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 09:19:06 -0400
In-Reply-To: <47038FAB.9020106@free.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-318885690-1191417543=:27745
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Wed, 3 Oct 2007, Cedric Le Goater wrote:

> Ilpo Järvinen wrote:
> > On Wed, 3 Oct 2007, Cedric Le Goater wrote:
> > 
> >> I'm dropping the previous patches you sent me and switching to this patchset. 
> >> right ?
> > 
> > Yes you can do that... However, there are two ways forward:
> > 
> > 1) Drop and test with this patchset long enough to verify it's gone...
> > 2) No dropping and get the more exact trace by reproducing, which can 
> >    point out to tcp_retrans_try_collapse confirming the source of the
> >    bug or revealing yet another bug...
> > 
> > The first one has one drawback, it cannot prove the fix very well since 
> > the bug could just not occur by chance... Path 2 would clearly show the 
> > place from where the problem originates because we will know that it got 
> > triggered! I personally would prefer path 2 but whether you want to go for 
> > that depends on the time you want to invest in it...
> > 
> > ...I rediffed the tcp_verify_fackets patch too (below) just in case it 
> > would be something else in you case and you choose path 1 (put it on top 
> > of this patchset, applies with some offsets). In case the problem is gone, 
> > it shouldn't trigger and if it does, we'll have another bug caught.
> 
> I have a spare node so I'm starting 2) with the 3 patches you sent and that
> last one which applied fine.

Ah, that's path 1) then... Since you seem to have enough time, I would say 
that the path 1 is good as well and bugs unrelated to the fix will show up 
there too...

I should have stated it explicitly that with path 2 those 3 patches should 
not be applied because the aim is not a fix but reproducal. Path 2 was 
intentionally left without the potentional fix as then nice backtrace 
informs when we can stop trying (which would hopefully occurred 
pretty soon) :-). But lets discard that path 2...

> all of them on a fresh git pull of net-2.6.24

That's fine, they're pretty well in sync (mm and net-2.6.24, and 
soon 2.6.24-rcs too).

-- 
 i.
---696243703-318885690-1191417543=:27745--
