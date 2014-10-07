From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1 net-next] af_unix: remove NULL assignment on static
Date: Tue, 07 Oct 2014 22:26:15 +0200
Message-ID: <1412713575.11600.4.camel@localhost>
References: <1412712996-4672-1-git-send-email-fabf@skynet.be>
	 <20141007.161832.453892039501955243.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fabf@skynet.be, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141007.161832.453892039501955243.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Di, 2014-10-07 at 16:18 -0400, David Miller wrote:
> From: Fabian Frederick <fabf@skynet.be>
> Date: Tue,  7 Oct 2014 22:16:36 +0200
> 
> > static values are automatically initialized to NULL
> > 
> > Signed-off-by: Fabian Frederick <fabf@skynet.be>
> 
> Isn't there some implementation room given to compilers
> as to the representation of true and false?

No, the standard requests implementations to implement false as 0 and
true as 1.

In case of assignments e.g. INT_MAX to _Bool (=bool) it will implicitly
converted to 1, so one can omit the often used !! with booleans.

Bye,
Hannes
