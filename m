From: "John S. Denker" <jsd@monmouth.com>
Subject: Re: ?completeness of IPsec feature-set
Date: Thu, 27 Mar 2003 16:48:37 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E8371B5.7030200@monmouth.com>
References: <3E82DCF7.7090706@monmouth.com> <20030327133659.GA11820@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030327133659.GA11820@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 03/27/2003 08:36 AM, bert hubert wrote:
>
> Racoon is just an IKE daemon - Linux is not bound to it.  

That's true.  But until today there had been no
discussion on netdev of any userspace tools except
KAME, as far as google and I can tell.  It seems
high time to begin such a discussion.

 > You are free to write your own.

I think before I did that I would throw away all
the linux-2.5 built-in IPsec features and use
FreeS/WAN, which has a reasonably complete feature-set.

It's amusing that some people flame FreeS/WAN,
alleging "it's _not_ integrated, and this is a
major problem" ... and alleging that the linux-2.5
stuff solves this problem.  Somehow I don't understand
how telling people to write their own key-exchange
daemon is the winning "integrated" solution.

 > The OpenBSD one (isakpmd) also works under linux.

Folks who wish to pursue this option are encouraged
to look at
   http://www.uwsg.iu.edu/hypermail/linux/kernel/0301.3/0582.html
which announces a port of isakmpd to linux-2.5,
available from
   http://bender.thinknerd.de/~thomas/isakmpd-linux-2.5/

BSD IPsec in general and isakmpd in particular have
a better design and vastly better documentation than
KAME.

However, the existence of isakmpd does not answer all
questions about the completeness of the IPsec feature-
set.

For example, BSD provides an "enc0" device and documents
using it to implement network security rules.  Alas I
see no sign that linux-2.5 provides this feature.  If
I am overlooking something, please explain.

I ask again:  Is there a document somewhere listing the
set of desirable features and the status thereof?  Or
otherwise is there something to reassure would-be users
that a complete feature-set will be provided?

http://www.monmouth.com/~jsd/vpn/ipsec+routing/feature-list.htm
