From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Silent corruption with r8169
Date: Thu, 5 Apr 2007 13:41:27 +0200
Message-ID: <20070405114127.GA19143@one.firstfloor.org>
References: <20070401012736.GT15189@vitelus.com> <20070401030315.GA24080@jim.sh> <20070401043905.GV15189@vitelus.com> <p737iswqjq4.fsf@bingen.suse.de> <20070404184504.GB7814@electric-eye.fr.zoreil.com> <20070404200603.GX15189@vitelus.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Andi Kleen <andi@firstfloor.org>, Jim Paris <jim@jtan.com>,
	linux-kernel@vger.kernel.org, linux-ide@vger.kernel.org,
	netdev@vger.kernel.org
To: Aaron Lehmann <aaronl@vitelus.com>
Return-path: <linux-ide-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070404200603.GX15189@vitelus.com>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> I'll try to get to testing this, but I'm wondering if people may have
> misunderstood my original post. I don't get any corruption over
> Ethernet; it's just corruption on the filesystem during certain load
> patterns that involve the Realtek ethernet card.

When disabling hardware checksums helps then you know the corruption
is on the Ethernetside. Otherwise it's somewhere else.

-Andi
