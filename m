From: jamal <hadi@cyberus.ca>
Subject: Re: [ANNOUNCE] Release of nf-HiPAC 0.9.0
Date: Mon, 26 Sep 2005 07:58:01 -0400
Message-ID: <1127735881.6215.294.camel@localhost.localdomain>
References: <200509260445.46740.mbellion@hipac.org>
	 <4337DA7C.2000804@cs.aau.dk>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Michael Bellion <mbellion@hipac.org>, linux-kernel@vger.kernel.org,
	linux-net@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751371AbVIZL6S@vger.kernel.org>
To: Emmanuel Fleury <fleury@cs.aau.dk>
In-Reply-To: <4337DA7C.2000804@cs.aau.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2005-26-09 at 13:24 +0200, Emmanuel Fleury wrote:
> Hi,
> 
> Did you solved your "size" issues when entering long list of rules ???
> 
> I'm still not convinced by your approach. :-/
> 
> These experiments have to be updated but can you comment on this:
> http://www.cs.aau.dk/~mixxel/cf/experiments.html

To repeat the tests i mentioned earlier for clarity:
a) Variable incoming packet rate (in packets per second)
b) Variable packet sizes
c) Variable number of users/filters
d) Effect of adding/removing/modifying policies while under different
incoming traffic rates.

You seem to have taken care of most of the variables involved except for
#d below. If you look at my slides you will see why #d is important to
have in modern firewalls. I think if you have to first compile rules
then you will have issues, but it remains to be seen.

Several comments:
- Am i mistaken that your source of data is from somewhere in the
backbone? Would it be fair to say that something in the edge would be
more appropriate?

- Your header extraction tool creates "10 sets of rules"; is there a
reason for the number 10?

- Is tcpreplay the right tool? What does it give you that you cant use a
better blaster like pktgen?

- I think the blackbox monitor looking at the input vs output tool is
good. It will be more complete if you can quantify the input rate then
you can easily quantify output rate.

- While your results were useful in showing Mbps; they are incomplete by
not mentioning the packet size. A better metric would have been pps. But
even then mentioning packet size is also useful.

If you are going to run these tests in stateless firewalling as you did,
please consider using tc filter as well.

cheers,
jamal
