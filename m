From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: tcp_sack problem Re: [Bug 11721] after upgrade to 2.6.27 i	cannot
 navigate
Date: Mon, 20 Oct 2008 12:58:59 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0810201256120.7072@wrl-59.cs.helsinki.fi>
References: <bug-11721-11547@http.bugzilla.kernel.org/>
 <20081018202056.F1933108040@picon.linux-foundation.org>
 <20081018210252.GA6048@ami.dom.local> <20081018215007.GB6048@ami.dom.local>
 <Pine.LNX.4.64.0810201106200.7072@wrl-59.cs.helsinki.fi>
 <20081020095118.GB6203@ff.dom.local>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1938506044-1224496739=:7072"
Cc: Aldo Maggi <sentiniate@tiscali.it>,
	Netdev <netdev@vger.kernel.org>, bugme-daemon@bugzilla.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47416 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750765AbYJTJ7C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Oct 2008 05:59:02 -0400
In-Reply-To: <20081020095118.GB6203@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1938506044-1224496739=:7072
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Mon, 20 Oct 2008, Jarek Poplawski wrote:

> On Mon, Oct 20, 2008 at 12:38:51PM +0300, Ilpo Järvinen wrote:
> ...
> > ...Might be something crazy in the way that is too picky on tcp option 
> > ordering which wouldn't surprise me that much... :-) Please try if
> > the patch below does any difference (on paperino is enough, the gw seems 
> > innocent here).
> 
> I've just thought about this too(!), and it seems that turning of
> tcp_timestamps should do similar reorder. But of course, I'll try
> not to disturb anymore...

Yeah, you should be right. No need to patch+compile+boot hassle him, 
turning timestamps should be "enough" to move mss into first slot... :-)

If that works we probably need to play around a bit to figure out what
is the actual cause (since it could involve timestamps or mss which the 
sysctl alone cannot prove).

-- 
 i.
---696208474-1938506044-1224496739=:7072--
