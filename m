From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: kenel level packet capturing
Date: Wed, 19 Oct 2011 14:30:25 +0200
Message-ID: <20111019123025.GA9320@netboy.at.omicron.at>
References: <CAKj1SsP+GE=QqN8nx7aaAxXE8BODKb=vns_=SnbyySQjZp3-pg@mail.gmail.com>
 <CAKj1SsOnYsOXjRBKm+=hTnEiesXrC3h0Q-KN2b61nPSQud9wMA@mail.gmail.com>
 <20111019.031314.1383303852454510720.davem@davemloft.net>
 <CADAe=++9WYg6nGH1vZ0BZKP5CDHO30i-pNVhBzgO9C-6FQX6cQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, raviraj.j1991@gmail.com,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netfilter@vger.kernel.org
To: Ajith Adapa <adapa.ajith@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADAe=++9WYg6nGH1vZ0BZKP5CDHO30i-pNVhBzgO9C-6FQX6cQ@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2011 at 02:22:35PM +0530, Ajith Adapa wrote:
> Yeah you are right David. But ..
> 
> For a newbie who just know more about linux userspace level need to
> know starting steps like where to start from and flow of packet might
> be confusing because of the level of abstraction being used. I guess
> it might take some time until you are really serious about making
> hands dirty :)

For working with or just reading kernel sources I recommend getting to
know the cscope tool. Do a "make cscope" and then use one of the front
end browsers.

If you use emacs, then you really should have this set

	; When working on the kernel
	(setq cscope-do-not-update-database t)

otherwise it tries to re-index after every search.

HTH,
Richard


