From: "Leonid Grossman" <leonid.grossman@neterion.com>
Subject: RE: [ANNOUNCE] Experimental Driver for Neterion/S2io 10GbE Adapters
Date: Tue, 15 Mar 2005 07:07:54 -0800
Message-ID: <200503151507.j2FF7sDD011131@guinness.s2io.com>
References: <200503150108.j2F18FDD016965@guinness.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>, <leonid@neterion.com>, <jgarzik@pobox.com>,
        "'Andi Kleen'" <ak@muc.de>
To: <alex@neterion.com>, <davem@davemloft.net>
In-Reply-To: <200503150108.j2F18FDD016965@guinness.s2io.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Alex Aizman writes:
> However, the main question remains: will the
> HAL-based driver (because even after the script-produced "surgery" it'll
> continue to be HAL based) ever get accepted?

Hi all, 
We truly appreciate the time spent on looking at the code and the feedback..

I guess Alex is asking the right question - before we start code changes, it
will be great to get a rough consensus on whether this HAL-based driver
(after suggested changes) will be acceptable to the community - or yet
another HAL driver in tree will be still "one too many"?

In particular - after this discussion, does David's statement below still
stand (not sure there was an unconditional rejection of the HAL model from
someone else)? 

>David Miller writes:
>I totally reject this driver, HAL is unacceptable for in-tree drivers.
>We've been over this a thousand times.

If this stands, we are prepared to recall the submission and keep the
current "Linux and everything else" status-quo for 10GbE Xframe drivers.
It's not the best maintenance option (both for us and arguably, even for a
non-primary-author kernel hackers) but it's workable.

Thanks again,
Leonid
