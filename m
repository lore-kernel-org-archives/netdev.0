From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: WARNING: at net/ipv4/tcp_input.c:2054 tcp_mark_head_lost()
Date: Sun, 2 Mar 2008 21:51:28 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0803022145210.18020@kivilampi-30.cs.helsinki.fi>
References: <858077.97160.qm@web39709.mail.mud.yahoo.com>
 <20080223000310.4630daa8.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0802271108290.13029@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0802271056l320a7ee2m5227e114a968d483@mail.gmail.com>
 <Pine.LNX.4.64.0802272120430.1741@kivilampi-30.cs.helsinki.fi>
 <Pine.LNX.4.64.0802281018480.32401@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0803020420ka42319bu1b9888217c869d9d@mail.gmail.com>
 <Pine.LNX.4.64.0803021432200.17919@kivilampi-30.cs.helsinki.fi>
 <3d8471ca0803020515m1e4af9d9xd37a8912e58a4504@mail.gmail.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; boundary="-696243703-662713104-1204487187=:18020"
Cc: Giangiacomo Mariotti <giangiacomo_mariotti@yahoo.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Guillaume Chazarain <guichaz@gmail.com>,
	Ray Lee <ray-lk@madrabbit.org>, Chris Wedgwood <cw@f00f.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59028 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752945AbYCBTvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Mar 2008 14:51:32 -0500
In-Reply-To: <3d8471ca0803020515m1e4af9d9xd37a8912e58a4504@mail.gmail.com>
Content-ID: <Pine.LNX.4.64.0803022147040.18020@kivilampi-30.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696243703-662713104-1204487187=:18020
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-ID: <Pine.LNX.4.64.0803022146411.18020@kivilampi-30.cs.helsinki.fi>

On Sun, 2 Mar 2008, Guillaume Chazarain wrote:

>> On Sun, Mar 2, 2008 at 1:38 PM, Ilpo Järvinen <ilpo.jarvinen@helsinki.fi> wrote:
>>> It does not contain any "KERNEL: assertion (packets <=
>> > tp->packets_out) failed at" line, so I'm afraid it's just noise.

Doh, you were right in this one...

>>  At least it catches one bug which could cause that assertion (it is much
>>  more rigid than the assertion and thus it catched it even though you
>>  won't see that assertion to ever trigger :-)).
>
> Great :-)

...I spoke too early, it was just that the verify call was placed into
a place where the fackets_out is not yet reduced (I had too many version 
of that patch when I first did that and probably picked wrong one of 
them as a starting point, I'm sorry about that). I'll send an updated 
patch tomorrow for you and also correct it so that I don't need to ask 
things like this again (as long as one pastes couple of first occuring 
stacktraces):

>>>  Could you next figure out what is at:


-- 
 i.
---696243703-662713104-1204487187=:18020--
