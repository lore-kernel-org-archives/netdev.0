From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH RFC] reciprocal_divide: correction/update of the algorithm
Date: Wed, 15 Jan 2014 00:25:38 +0100
Message-ID: <20140114232538.GD29887@pd.tnic>
References: <20140113214249.GK6586@order.stressinduktion.org>
 <1389722825.31367.260.camel@edumazet-glaptop2.roam.corp.google.com>
 <52D58E6F.4050000@gmail.com>
 <1389729032.31367.262.camel@edumazet-glaptop2.roam.corp.google.com>
 <52D5A3DC.9030107@gmail.com>
 <1389739537.31367.273.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Austin S Hemmelgarn <ahferroin7@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, dborkman@redhat.com,
	linux-kernel@vger.kernel.org, darkjames-ws@darkjames.pl
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1389739537.31367.273.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 14, 2014 at 02:45:37PM -0800, Eric Dumazet wrote:
> Even on a Jaguar, the proposed alternative

I don't know what Jaguar you guys are talking about but the Jaguar
I know - Fam16h - has an int hardware divider:

http://developer.amd.com/wordpress/media/2012/10/SOG_16h_52128_PUB_Rev1_1.pdf

So all that talk about microcode is plain wrong. The hardware divider
comes from Llano (F12h) so it must be some other Jaguar, maybe Bobcat.

:-)

If it is Bobcat, then it has a 1-bit per cycle ucode int divider.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--
