From: bert hubert <ahu@ds9a.nl>
Subject: Re: ?completeness of IPsec feature-set
Date: Thu, 27 Mar 2003 22:58:39 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030327215839.GA31029@outpost.ds9a.nl>
References: <3E82DCF7.7090706@monmouth.com> <20030327133659.GA11820@outpost.ds9a.nl> <3E8371B5.7030200@monmouth.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "John S. Denker" <jsd@monmouth.com>
Content-Disposition: inline
In-Reply-To: <3E8371B5.7030200@monmouth.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 27, 2003 at 04:48:37PM -0500, John S. Denker wrote:

> I think before I did that I would throw away all the linux-2.5 built-in
> IPsec features and use FreeS/WAN, which has a reasonably complete
> feature-set.

:-) 

> It's amusing that some people flame FreeS/WAN, alleging "it's _not_
> integrated, and this is a major problem" ... and alleging that the
> linux-2.5 stuff solves this problem.  Somehow I don't understand how
> telling people to write their own key-exchange daemon is the winning
> "integrated" solution.

I sense some... anger. Linux provides the RFC PF_KEY protocol and also uses
the RFC ioctls to support IPSEC. Any compliant IKE will work against it.
That is how development works in the kernel.

> For example, BSD provides an "enc0" device and documents using it to
> implement network security rules.  Alas I see no sign that linux-2.5
> provides this feature.  If I am overlooking something, please explain.

'enc0' is an internal abstraction, do you need it? 

> I ask again:  Is there a document somewhere listing the set of desirable
> features and the status thereof?  Or otherwise is there something to
> reassure would-be users that a complete feature-set will be provided?

Right now, the kernel side of things is nearly complete. I sorely miss IPSEC
NAT traversal which appears to be pretty patented.

> http://www.monmouth.com/~jsd/vpn/ipsec+routing/feature-list.htm

This is mostly about userspace. The current attitude is that the kernel
provides the hooks and we then hope people start coding against that
interface. A large amount of the things you suggest can be implemented
today.

Some time ago I took a small shot at porting the freeswan ike to the
standardised IPSEC ioctls add PF_KEY protocol but it differed too wildly. It
may well be useful to continue this effort.

Regards,

bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
http://netherlabs.nl                         Consulting
