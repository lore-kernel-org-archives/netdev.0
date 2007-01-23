From: "Jon Smirl" <jonsmirl@gmail.com>
Subject: Re: [PATCH] Marvell Libertas 8388 802.11b/g USB driver (v2)
Date: Tue, 23 Jan 2007 11:18:27 -0500
Message-ID: <9e4733910701230818g13dc82a2kf0972b8543db449f@mail.gmail.com>
References: <20070116185524.GA5681@dmt>
	 <20070117141103.0e468bf4@griffin.suse.cz>
	 <1169046072.2750.10.camel@localhost.localdomain>
	 <1169047134.9175.49.camel@johannes.berg>
	 <1169055788.2550.44.camel@localhost.localdomain>
	 <1169056884.9175.66.camel@johannes.berg> <20070122112613.GA3038@dmt>
	 <9e4733910701220720x47506091m357cbf9e5deb3903@mail.gmail.com>
	 <1169566914.3649.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Marcelo Tosatti" <marcelo@kvack.org>,
	"Dan Williams" <dcbw@redhat.com>, "Jiri Benc" <jbenc@suse.cz>,
	netdev <netdev@vger.kernel.org>,
	"Jeff Garzik" <jgarzik@pobox.com>,
	"John W. Linville" <linville@redhat.com>,
	"Luis R. Rodriguez" <mcgrof@gmail.com>,
	"Arnd Bergmann" <arnd@arndb.de>,
	"Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:48317 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933042AbXAWQS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 11:18:28 -0500
Received: by py-out-1112.google.com with SMTP id a29so817501pyi
        for <netdev@vger.kernel.org>; Tue, 23 Jan 2007 08:18:27 -0800 (PST)
To: "Johannes Berg" <johannes@sipsolutions.net>
In-Reply-To: <1169566914.3649.4.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/23/07, Johannes Berg <johannes@sipsolutions.net> wrote:
> On Mon, 2007-01-22 at 10:20 -0500, Jon Smirl wrote:
>
> > What is the general solution for 802.11s?
>
> None yet.
>
> > I'm working on an embedded
> > design that would benefit from 11s support and I'd rather not have to
> > roll my own mesh implementation in user space.
>
> Well, there is no mesh implementation that I'm aware of, you'll want to
> stick it along with the userspace MLME into wpa_supplicant.

Is the 802.11s Draft 1.0 spec publicly available yet? It is supposed
to be making changes at the very lowest MAC layers. It will be hard to
be compatible with that from user space.

> > I'd also like to get an
> > idea of what kind of hardware I need to design onto my board given
> > that the 8388 is not available general consumption. My system has
> > plenty of power and CPU available so a softmac type 11s solution is
> > the most cost effective. It seems to me that the design of a software
> > based 11s stack should be coordinated with the 8388 firmware one.
>
> It should, but afaik no one is really working on it either way.

The software doesn't have to be written but there should be at least
some design work done on how 11s should fit into the existing world
for both a firmware and software implementation. I'd hate to see a
different implementation for each vendor and another one for the
software stack.

-- 
Jon Smirl
jonsmirl@gmail.com
