From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Replace infinite loop on recvmsg bug with proper
 crashusers
Date: Wed, 07 Nov 2012 08:29:12 -0800
Message-ID: <1352305752.3140.4449.camel@edumazet-glaptop>
References: <1352247335-10396-1-git-send-email-jwerner@chromium.org>
	 <20121107013907.GA31185@redhat.com>
	 <CAODwPW-636Sn3B4CYajvrgccXxresZwPLg2UFz6xDDk9-FfTYQ@mail.gmail.com>
	 <20121107155434.GA17677@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Julius Werner <jwerner@chromium.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	James Morris <jmorris@namei.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"David S. Miller" <davem@davemloft.net>,
	Sameer Nanda <snanda@chromium.org>,
	Mandeep Singh Baines <msb@chromium.org>,
	Eric Dumazet <edumazet@chromium.org>
To: Dave Jones <davej@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20121107155434.GA17677@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-11-07 at 10:54 -0500, Dave Jones wrote:

> It sounds more appropriate to me, instead of silently wedging the box.
> At least with that approach we have a chance of finding out what happened.

Its quite the opposite.

If bug is still there 6 months after the commits that broke the drivers,
(making an old bug visible) that means that people never realized the
bug was there.

I understand a distro maintainer has its own choices, but for upstream
kernel we want to have early reports.

This bug is fatal and a security issue. BUG() is appropriate.

If the driver cant be fixed, it should be marked broken.

So I personally NACKed patch to hide the bug, trying to be friendly to
the user.
