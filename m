From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: Soft lockup issue in Linux 4.1.9
Date: Fri, 2 Oct 2015 23:04:29 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1510022302430.4500@nanos>
References: <1443650383.13282.10.camel@daevel.fr>  <560D1223.3070606@googlemail.com>  <CANn89i+B5T4Rhs8HnrC0+f+GhLvBFfpr4BVDvhkVOveSfy9B8Q@mail.gmail.com>  <560D1C5A.3050508@googlemail.com>  <CANn89iKvTUKZTiWQYbjXLr4NvYKDgd_mKYVzZHiSqk0e0OfGxA@mail.gmail.com>
  <alpine.DEB.2.11.1510022200130.4500@nanos> <1443819583.32531.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <edumazet@google.com>,
	=?ISO-8859-15?Q?Holger_Hoffst=E4tte?=
	<holger.hoffstaette@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443819583.32531.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2 Oct 2015, Eric Dumazet wrote:
> On Fri, 2015-10-02 at 22:04 +0200, Thomas Gleixner wrote:
> 
> > What makes sure, that the timer cannot be readded while that timer
> > callback is running?
> 
> What is exactly your question ?

CPU0   	  	       		CPU1

timer expires
  callback
				add timer
  timer_pending() == true
  ===> del_timer_sync()

I was just curious how this is prevented as I got lost in the
networking code as usual :)

Thanks,

	tglx
