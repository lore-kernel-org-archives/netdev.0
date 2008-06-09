From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Mon, 9 Jun 2008 22:24:06 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0806091422180.16829@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu>  <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
  <484191BD.8000904@gmail.com>  <Pine.LNX.4.64.0805312119270.2672@wrl-59.cs.helsinki.fi>
  <a01a16b50805311325w7f58ca69h93d02af9bc28d2ea@mail.gmail.com>
 <Pine.LNX.4.64.0805312332270.2760@wrl-59.cs.helsinki.fi>
 <a01a16b50806031710u54b9297bkf1fad9c4f8fd581f@mail.gmail.com>
 <Pine.LNX.4.64.0806041402211.16829@wrl-59.cs.helsinki.fi>
 <a01a16b50806040700h1efce63cq2a27b087df0d25be@mail.gmail.com>
 <Pine.LNX.4.64.0806041802360.2580@wrl-59.cs.helsinki.fi>
 <a01a16b50806060232u1eff3867u24fecc539fda1d14@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696208474-378399390-1213010651=:16829"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?UTF-8?Q?H=C3=A5kon_L=C3=B8vdal?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:48383 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750728AbYFITYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 15:24:09 -0400
In-Reply-To: <a01a16b50806060232u1eff3867u24fecc539fda1d14@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0806092222010.19938@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-378399390-1213010651=:16829
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0806092222011.19938@wrl-59.cs.helsinki.fi>

On Fri, 6 Jun 2008, Håkon Løvdal wrote:

> On 04/06/2008, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
> > I guess not all of the strace will be necessary anyway. You could first
> > leave that out completely and concentrate on the other logs first.
> 
> I have now set up a server on my machine and made all logs available.
> I will follow up with the adress in private email to those that already
> have posted in this thread. For others, please ask to receive it.

Can you please explain this:

ijjarvin@wrl-59:~/tmp$ bunzip2 -t copytest003.capture.bz2 
bunzip2: copytest003.capture.bz2: data integrity (CRC) error in data

You can use the `bzip2recover' program to attempt to recover
data from undamaged sections of corrupted files.

ijjarvin@wrl-59:~/tmp$ ls -al copytest003.capture.bz2 
-rw-r----- 1 ijjarvin tkol 275441620  9. kesÃ¤Â Â  16:39 
copytest003.capture.bz2
ijjarvin@wrl-59:~/tmp$ md5sum copytest003.capture.bz2 
4bbf801cf1fbd52399322b088c1a2058  copytest003.capture.bz2
ijjarvin@wrl-59:~/tmp$ 

...also the one from allfiles.zip is similarily damaged.

...If you don't have an explanation, them it might be time to check
your hardware....

-- 
 i.
---696208474-378399390-1213010651=:16829--
