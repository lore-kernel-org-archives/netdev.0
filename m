From: Johan Hedberg <johan.hedberg@gmail.com>
Subject: Re: [PATCH] bluetooth.h: __ variants of u8 and friends are not
 neccessary inside kernel
Date: Thu, 6 Oct 2016 11:38:04 +0300
Message-ID: <20161006083804.GA2993@x1c.lan>
References: <20161003085640.GA8130@amd>
 <368810F9-519C-44B5-85D4-1815273438BF@holtmann.org>
 <1475689996.6105.11.camel@perches.com>
 <20161005191103.GA25972@amd>
 <1475694934.1941.1.camel@perches.com>
 <20161005221317.GA21551@amd>
 <1475706531.1941.4.camel@perches.com>
 <20161006070237.GB25972@amd>
 <1475737676.3224.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pavel Machek <pavel@ucw.cz>, Marcel Holtmann <marcel@holtmann.org>,
        "Gustavo F. Padovan" <gustavo@padovan.org>,
        "David S. Miller" <davem@davemloft.net>,
        linux-bluetooth@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1475737676.3224.1.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Oct 06, 2016, Joe Perches wrote:
> On Thu, 2016-10-06 at 09:02 +0200, Pavel Machek wrote:
> > I believe you are wrong. bit addressability does not matter, cpu can
> > definitely get the bit values.
> > 
> > u8 foo:1;
> > u8 bar:1;
> > u8 baz:1;
> > 
> > should take 1 byte, where
> > 
> > bool foo, bar, baz;
> > 
> > will take more like 3.
> 
> Definitely true.
> 
> There is only one single bitfield foo here though
> so what you wrote doesn't apply.

What's in the tree is a left-over from times when there were multiple
bit fields in this struct. By the time others were removed and there was
only one left no-one has apparently bothered to update it to a bool or
single u8.

Johan
