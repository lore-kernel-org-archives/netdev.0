From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 1/3] wimax: fix '#ifdef CONFIG_BUG' layout to avoid
 warning
Date: Wed, 7 Jan 2009 21:42:53 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0901072139001.27541@wrl-59.cs.helsinki.fi>
References: <cover.1231314782.git.inaky@linux.intel.com>
 <8baeb9679011f4f01a5f9709c725c4d829cb28bd.1231314782.git.inaky@linux.intel.com>
 <Pine.LNX.4.64.0901071200080.27307@wrl-59.cs.helsinki.fi>
 <200901070920.18032.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-1266802129-1231357264=:27541"
Cc: Netdev <netdev@vger.kernel.org>, wimax@linuxwimax.org,
	greg@kroah.com
To: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:33131 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756251AbZAGTmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jan 2009 14:42:55 -0500
In-Reply-To: <200901070920.18032.inaky@linux.intel.com>
Content-ID: <Pine.LNX.4.64.0901072141510.27541@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1266802129-1231357264=:27541
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0901072141511.27541@wrl-59.cs.helsinki.fi>

On Wed, 7 Jan 2009, Inaky Perez-Gonzalez wrote:

> On Wednesday 07 January 2009, Ilpo Järvinen wrote:
> > On Tue, 6 Jan 2009, Inaky Perez-Gonzalez wrote:
> > > Reported by Randy Dunlap:
> > > > Also, this warning needs to be fixed:
> > > >
> > > > linux-next-20090106/net/wimax/id-table.c:133: warning: ISO C90
> > > > forbids mixed declarations and code
> > >
> > > Move the return on #defined(CONFIG_BUG) below the variable
> > > declarations so it doesn't violate ISO C90.
> > >
> > > On wimax_id_table_release() we want to do a debug check if CONFIG_BUG
> > > is enabled. However, we also want the debug code to be always compiled
> > > to ensure there is no bitrot.
> >
> > I hope this kind of solution won't add some warnings? Besides, this seems
> > rather strange reasoning as CONFIG_BUG is mostly enabled anyway?
> 
> Well, it is legal code -- short of 'if (1) return'. It doesn't warn (and 
> it should not).

Obviously, but I was concerned on the other lines than that 
particular one, e.g., gcc might think that wimax_dev is unused 
variable and emit a warning or along those lines...?


-- 
 i.
---696208474-1266802129-1231357264=:27541--
