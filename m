From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: wireless 2.6 work
Date: Tue, 22 Mar 2005 21:15:52 -0500
Message-ID: <4240D158.1060302@pobox.com>
References: <20050310025036.GE17854@ruslug.rutgers.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@oss.sgi.com>, Dan Williams <dcbw@redhat.com>,
        vkondra@mail.ru, Linux Kernel <linux-kernel@vger.kernel.org>
To: "Luis R. Rodriguez" <mcgrof@ruslug.rutgers.edu>
In-Reply-To: <20050310025036.GE17854@ruslug.rutgers.edu>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Luis R. Rodriguez wrote:
> Jeff,
> 
> I'm sick off the low activiity and slow support on wireless we have. I
> know you're busy so I wanted to offer my help in helping around work on
> wireless-2.6, now that I have time after work, and before I commit
> myself to anything else. It's a bit suicidal, but oh well. Oh yeah and
> I'll also start using bitkeeper due to the recent clarifications on the
> license of its usage.

Great!  While I think BitKeeper is useful, you are more than welcome to 
continue sending patches.

To wireless developers, BitKeeper will mainly be of use in sync'ing with 
the latest wireless-2.6 tree.


> I'll willing to review as much patches as I have to and also hopefully
> write documentation on writing new wireless drivers. That said, if I can
> be of any assistance, where what you like me to start on?
> 
> Here's what's on my agenda so far:
> 
> * Help cleanup new ralink driver, start using ieee802211 and get into wireless-2.6.
> * Push prism54's new WPA and WDS support into wireless-2.6
> * Start seeing what I can use off of ieee80211 for prism54, clean it,
>   and move to wireless-2.6
> * Start incorporating WPA through wpa_supplicant onto as many drivers
> * Start standardizing all things a bit, as bitched about and well pointed out
>   by Dan Williams <dcbw@redhat.com>
> * Listen to Jouni, he's the man

Well, all this sounds good to me.  See also the 'status' post I just 
made, and the 'note on wireless development process' I am about to write.

I'm really hoping someone will look into integrating wireless 802.11 as 
a "real" protocol, rather than faking ethernet.  This work starts with 
the "p80211" template DaveM provided, and hopefully continues with 
Vladimir's updates of DaveM's code (did he post those anywhere?).  There 
are also issues such as ARP types that Dan Williams mentioned to me as 
issues.

The "integrate wireless into net stack" work requires a very 
self-motivated person who is willing to poke into the net stack, and 
answer their own questions.

	Jeff
