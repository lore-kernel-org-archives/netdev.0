From: jamal <hadi@cyberus.ca>
Subject: Re: Asynchronous crypto layer.
Date: 30 Oct 2004 19:41:27 -0400
Message-ID: <1099179687.1041.117.camel@jzny.localdomain>
References: <1099030958.4944.148.camel@uganda>
	 <1099053738.1024.104.camel@jzny.localdomain>
	 <20041029180652.113f0f6e@zanzibar.2ka.mipt.ru>
	 <20041030203550.GB6256@gate.ebshome.net>
	 <20041031010415.4c798a04@zanzibar.2ka.mipt.ru>
	 <20041030205630.GD6256@gate.ebshome.net>
	 <20041031012423.74b98698@zanzibar.2ka.mipt.ru>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eugene Surovegin <ebs@ebshome.net>, netdev@oss.sgi.com,
        cryptoapi@lists.logix.cz
Return-path: <netdev-bounce@oss.sgi.com>
To: johnpol@2ka.mipt.ru
In-Reply-To: <20041031012423.74b98698@zanzibar.2ka.mipt.ru>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2004-10-30 at 17:24, Evgeniy Polyakov wrote:
> On Sat, 30 Oct 2004 13:56:31 -0700
> Eugene Surovegin <ebs@ebshome.net> wrote:


> > OK, what about 64 byte packets? I'm not saying hw crypto is useless, 
> > what I'm saying is it's not that obvious that having hw crypto will 
> > help in _all_ situations.
> 
> Sure.
> For such cases I offered "rate" or "speed" parameter in my first e-mail, 
> but it can be implicitly implemented by queue length.
> With 1 big datflow of packets with high priority and little dataflow of
> packets with little priority if we will catch high priority packets by SW
> and thus can have situation when we will _never_ catch low-priority packets, 
> with even very slow HW we can route all those low-priority packets into it, 
> at least they will be processed sometimes...

Can you explain the "rate" or "speed" parameter ?
I havent studied your code, however, what Eugene is pointing out is
valuable detail/feedback.
You should have in your queuing towards the crypto chip ability to
batch. i.e sort of nagle-like "wait until we have 10 packets/20KB or 20
jiffies" before you send everything in the queue to the chip.
As he points out (and i am sure he can back it with data ;->), that
given the setup cost, packet size, algo and CPU and bus speed, it may
not make sense to use the chip at all ;->

cheers,
jamal
