From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/core: Fix seeking in /proc/net/dev
Date: Fri, 06 Apr 2012 19:41:19 +0200
Message-ID: <1333734079.3007.4.camel@edumazet-glaptop>
References: <1333731944-15808-1-git-send-email-john@keeping.me.uk>
	 <CAOMsUMLDFpYw9REPjZd2m49xV4UKFjFobNorGmOPCFeqjV-RDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Keeping <john@keeping.me.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Mihai Maruseac <mihai.maruseac@gmail.com>,
	Daniel Baluta <dbaluta@ixiacom.com>
To: Mihai Maruseac <mmaruseac@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAOMsUMLDFpYw9REPjZd2m49xV4UKFjFobNorGmOPCFeqjV-RDg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-04-06 at 20:14 +0300, Mihai Maruseac wrote:
> On Fri, Apr 6, 2012 at 8:05 PM, John Keeping <john@keeping.me.uk> wrote:
> > Commit f04565ddf52e4 (dev: use name hash for dev_seq_ops) introduced
> > code that fails to check the requested position when getting an item for
> > /proc/net/dev.  This means that any code which seeks within this file is
> > likely to receive corrupted data.
> >
> > A test case for this is to use the read builtin in bash:
> >
...
> Looks good to me. However, Eric just submitted a patch here with other
> changes caused by a logic error in the original patch.

Hmm, I think my patch fixed this lseek issue as well.
