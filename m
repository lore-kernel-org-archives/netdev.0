From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [2.6 patch] do not select NET_CLS
Date: Thu, 24 Nov 2005 06:40:02 +0100
Message-ID: <20051124054001.GB7618@mars.ravnborg.org>
References: <4381F2D2.5000605@trash.net> <20051122.143713.101129339.davem@davemloft.net> <20051122224914.GA17575@mars.ravnborg.org> <20051122.150041.90521592.davem@davemloft.net> <20051123055735.GC7579@mars.ravnborg.org> <20051123181332.0f86bfdb.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, kaber@trash.net, bunk@stusta.de,
	evil@g-house.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, zippel@linux-m68k.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161006AbVKXFkF@vger.kernel.org>
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <20051123181332.0f86bfdb.rdunlap@xenotime.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 23, 2005 at 06:13:32PM -0800, Randy.Dunlap wrote:
> 
> So -q means "quick" ?
>From make help:
-q, --question Run no commands; exit status says if up to date

> I wouldn't mind seeing a -quiet (even less quiet than V=0),
> not even printing the CC, AS, LD, etc. commands -- just let the
> tools print errors & warnings.  I always redirect output to a
> disk file and filter it for errors and warnings anyway, so I
> want hold my breath for this, but ISTM that V=0 could be even
> quieter than it is right now.

make -s shuld give you this. I've not used it for long though...

	Sam
