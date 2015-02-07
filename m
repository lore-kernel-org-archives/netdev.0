From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 2/6] drivers: isdn: act2000: capi.c: fix checkpatch
 errors
Date: Sat, 07 Feb 2015 21:43:20 +0100
Message-ID: <1423341800.2246.68.camel@x220>
References: <1423328797-17865-1-git-send-email-baspeters93@gmail.com>
	 <1423328797-17865-3-git-send-email-baspeters93@gmail.com>
	 <54D650BF.5000400@cogentembedded.com> <1423336761.2933.7.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tilman Schmidt <tilman@imap.cc>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Bas Peters <baspeters93@gmail.com>, isdn@linux-pingi.de,
	julia.lawall@lip6.fr, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423336761.2933.7.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[Adding Tilman.]

On Sat, 2015-02-07 at 11:19 -0800, Joe Perches wrote:
> Does anyone still use these cards?

0) Good question.

1) None of the (two dozen) commits in drivers/isdn/act2000/ added since
v2.6.12 appear to be triggered complaints, suggestions, etc. of actual
users.

2) Broader picture: if I remember correctly there are now four different
flavors of ISDN in the kernel:
- really old: pre-i4l
- very old: i4l
- just old: CAPI
- not so old: mISDN

I could spend another 24 hours refining and relabeling these categories,
and matching the various drivers to these categories. But I'm pretty
sure none of the current categories contain all the drivers. And I'm
certain all current categories support one or more drivers that none of
the other categories do. So the current ISDN situation is a bit messy.

Tilman might be able to provide a clearer, and maybe less grumpy,
summary of the current situation.

3) Anyhow, this is an i4l card. i4l is deprecated since v2.6.22. And it
was obsolete before that!

4) Furthermore, it seems consumer grade ISDN is on the way out. Eg, my
ISP will disconnect my, let's call it, ADSL over ISDN connection in less
that two months because they can't be bothered anymore to support that
niche. 

5) So we could let the various flavors of ISDN limp along for another
few years. But maybe we should consider, say, removing i4l and pre i4l
and see who complains. That might be a rude thing to do. So perhaps the
various ISDN flavors should be left alone until ... what exactly?


Paul Bolle
