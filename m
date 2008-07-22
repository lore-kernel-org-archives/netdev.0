From: David Miller <davem@davemloft.net>
Subject: Re: [crash] BUG: unable to handle kernel NULL pointer dereference
 at 0000000000000370
Date: Tue, 22 Jul 2008 04:32:20 -0700 (PDT)
Message-ID: <20080722.043220.247312412.davem@davemloft.net>
References: <4885104A.2070201@lwfinger.net>
	<20080721.161517.27161039.davem@davemloft.net>
	<48857F74.2040406@lwfinger.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, mingo@elte.hu, ischram@telenet.be,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-wireless@vger.kernel.org, j@w1.fi
To: Larry.Finger@lwfinger.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754982AbYGVLcg@vger.kernel.org>
In-Reply-To: <48857F74.2040406@lwfinger.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Larry Finger <Larry.Finger@lwfinger.net>
Date: Tue, 22 Jul 2008 01:34:28 -0500

> David Miller wrote:
> > From: Larry Finger <Larry.Finger@lwfinger.net>
> > Date: Mon, 21 Jul 2008 17:40:10 -0500
> > 
> >> Sorry :(
> >>
> >> I used the davem patch, the second version of your first one, and your second 
> >> one. Both problems persist.
> >>
> >> Still plugging away on bisection.
> > 
> > GIT bisecting the lockdep problem is surely going the land you on:
> > 
> > commit e308a5d806c852f56590ffdd3834d0df0cbed8d7
> 
> No. It landed on this one.

For the lockdep warnings?
