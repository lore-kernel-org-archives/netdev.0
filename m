From: Andi Kleen <ak@muc.de>
Subject: Re: Do you know the linux TCP stack?
Date: Sat, 05 Mar 2005 19:34:22 +0100
Message-ID: <m1wtsmrlg1.fsf@muc.de>
References: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Zdenek Radouch <zdenek@rcn.com>
In-Reply-To: <E1D7aML-0007Wp-00@smtp01.mrf.mail.rcn.net> (Zdenek Radouch's
 message of "Sat, 05 Mar 2005 09:31:32 -0500")
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Zdenek Radouch <zdenek@rcn.com> writes:
>
> If you can do it, and are interested in helping me,  please send me
> a note, with your hourly consulting rate, or a suggestion of how
> you'd like to be compensated for the work.  Of course, if you'd
> like to just send me an answer, that would be fine, too. :-)

((struct rtentry *)(skb->dst))->rt_spec_dst

You would need to make sure the packet is IP first, and even then
it may fail (e.g. injected IP packet from a packet socket)

-Andi
