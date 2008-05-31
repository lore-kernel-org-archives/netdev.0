From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [bug] stuck localhost TCP connections, v2.6.26-rc3+
Date: Sat, 31 May 2008 20:22:23 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0805312020520.2672@wrl-59.cs.helsinki.fi>
References: <20080526115628.GA31316@elte.hu> <1211966834.12349.62.camel@twins>
 <a01a16b50805310725x4f1c375ep2d091bb044ac0787@mail.gmail.com>
 <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/Mixed; boundary="-696208474-1647873004-1212250192=:2657"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	"David S. Miller" <davem@davemloft.net>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	Andrew Morton <akpm@linux-foundation.org>
To: "=?ISO-8859-1?Q?H=E5kon_L=F8vdal?=" <hlovdal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:47995 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752768AbYEaRWZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2008 13:22:25 -0400
In-Reply-To: <Pine.LNX.4.64.0805311839540.2657@wrl-59.cs.helsinki.fi>
Content-ID: <Pine.LNX.4.64.0805312020521.2672@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1647873004-1212250192=:2657
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0805312020522.2672@wrl-59.cs.helsinki.fi>

On Sat, 31 May 2008, Ilpo Järvinen wrote:

> On Sat, 31 May 2008, Håkon Løvdal wrote:
> 
> > posted a few days ago are somewhat different from mine, however I believe
> > this is the same problem or at least related. Just as Ingo experienced,
> > netstat -p only shows PID/program as '-' for the hung connections while
> > for other connections it shows the expected results.
> 
> Hmm, are the other end's processes still there? ...I'd be interested to 
> know what they're doing at the moment...

I meant that end where you see this '-'. I suppose it's easy for you to 
figure out which process is the right one, something that wouldn't be so 
easy with the Ingo's test case which forks/exits numerous times.

-- 
 i.
---696208474-1647873004-1212250192=:2657--
