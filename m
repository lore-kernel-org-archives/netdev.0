From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: Delete an unnecessary check before the
 function call "put_device"
Date: Mon, 16 Nov 2015 15:11:56 -0500 (EST)
Message-ID: <20151116.151156.22243959928293016.davem@davemloft.net>
References: <alpine.DEB.2.02.1402262129250.2221@localhost6.localdomain6>
	<5317A59D.4@users.sourceforge.net>
	<56476B8C.7020309@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org, julia.lawall@lip6.fr
To: elfring@users.sourceforge.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56476B8C.7020309@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'm starting to grow quite weary of these "unnecessary check" changes.

Sometimes it is better to have them, either because the path is a hot
path or some atomic sequence is involved.

But there is never harm in them being there.

All of this is a matter of taste, of course.  But one thing I know for
sure, it is undisputable that there are much more important things to
work on than this kind of stuff...

So I'm not applying these changes any more and directing my time and
effort to reviewing and applying patches that fix bugs, really
restructure the code in useful ways that increase maintainability over
the long time, and add interesting new features.

These patches do none of the above.
