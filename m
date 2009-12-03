From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 14:44:04 +0200 (EET)
Message-ID: <alpine.DEB.2.00.0912031430170.7024@wel-95.cs.helsinki.fi>
References: <20091130213727.2f4047d2@houba> <alpine.DEB.2.00.0911302244160.9826@melkinpaasi.cs.helsinki.fi> <20091201211945.505d3c98@houba> <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi> <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi> <20091202154403.GB30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <20091203131127.131e9122@houba>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="8323329-1153730101-1259843689=:7024"
Cc: Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Frederic Leroy <fredo@starox.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:53376 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751787AbZLCMn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 07:43:59 -0500
In-Reply-To: <20091203131127.131e9122@houba>
Content-ID: <alpine.DEB.2.00.0912031435220.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323329-1153730101-1259843689=:7024
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Content-ID: <alpine.DEB.2.00.0912031435221.7024@wel-95.cs.helsinki.fi>

On Thu, 3 Dec 2009, Frederic Leroy wrote:

> Le Thu, 3 Dec 2009 12:29:39 +0200 (EET),
> "Ilpo Järvinen" <ilpo.jarvinen@helsinki.fi> a écrit :
> 
> > Opinions, Dave?, Greg?
> > 
> > Now back to the issue...
> > 
> > You said in the other mail that "All further test are on linus-stable 
> > tree.", which has this contradiction that Linus does not maintain
> > stable trees. Which exactly was the tree used for the .9. test
> 
> Sorry I'm confused and so confuse you.
> For .9 .10 and now I'm only using : 
> git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux-2.6.git

Thanks for the confirmation.

> > Nice thinking indeed Damian, thanks. ...But but, where exactly did
> > you print? ...There are multiple returns and the return false branch
> > is expected to have a zero retrans_stamp in a typical case but that
> > is not a problem because we never use the value.
> 
> Here is the code :
> http://www.starox.org/pub/scp_stall/printk_retrans_stamp.patch

So I was wrong.

> > Also, we have the another mystery to be solved, the fast
> > retransmission is not triggered for some reason (or alternatively not
> > captured in to a log), even in the working .9. case. It would be easy
> > to see whether it works at all from TCP point of view by looking into
> > mibs once you have have some transfers in a working configuration:
> > 
> > grep -A1 TCP /proc/net/netstat
> 
> I will try this evening. I can do test only outside office hours.

Ok. Please take before test and after test capture to allow easy 
compare of what changed.

-- 
 i.
--8323329-1153730101-1259843689=:7024--
