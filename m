From: "John S. Denker" <jsd@monmouth.com>
Subject: Re: ?completeness of IPsec feature-set
Date: Thu, 27 Mar 2003 17:58:06 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E8381FE.5050603@monmouth.com>
References: <3E82DCF7.7090706@monmouth.com> <20030327133659.GA11820@outpost.ds9a.nl> <3E8371B5.7030200@monmouth.com> <20030327215839.GA31029@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>
In-Reply-To: <20030327215839.GA31029@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 03/27/2003 04:58 PM, bert hubert wrote:
> 
> Linux provides the RFC PF_KEY protocol and also uses
> the RFC ioctls to support IPSEC. Any compliant IKE will work against it.
 > That is how development works in the kernel.

Saying it's not a kernel problem isn't the same
as saying it's not a problem.  I was told this
was the proper list to raise such questions.  If
it isn't, please point me to a more-appropriate
list.

Certain parties are touting linux-2.5 IPsec as
a complete and "integrated" solution.  Either
the claims need to be toned down or (preferably)
thelevel of integration needs to go up.  In any
case a "status report" clarifying what remains
to be done would be helpful.

>>For example, BSD provides an "enc0" device and documents using it to
>>implement network security rules.  Alas I see no sign that linux-2.5
>>provides this feature.  If I am overlooking something, please explain.
> 
> 'enc0' is an internal abstraction, do you need it? 

We agree is an abstraction... but I wouldn't have
called it "internal".  It is a documented interface,
so the better half of it is external.

As to need, I get 1290 hits from
   http://www.google.com/search?q=enc0
so there is prima facie evidence that people use it.

Uses include
  -- mentioning it in packet-filtering rules.
  -- using it to communicate with userspace about
     things like MTU and default source address.
  -- mentioning it in routing rules.

If you have evidence that everything that can be
done with enc0 can be conveniently done without
enc0, please share it.

> Right now, the kernel side of things is nearly complete. I sorely miss IPSEC
> NAT traversal which appears to be pretty patented.

Do you mean these patents
   http://www.ietf.org/ietf/IPR/SSH-NAT
or others?

Also, I have heard reports that NAT-traversal
was "coming soon" to linux-2.5.  Again, a
coherent status report would be helpful.

>>http://www.monmouth.com/~jsd/vpn/ipsec+routing/feature-list.htm
> 
> 
> This is mostly about userspace. The current attitude is that the kernel
> provides the hooks and we then hope people start coding against that
> interface. A large amount of the things you suggest can be implemented
> today.

A large amount, yes.  But perhaps not all;  the
enc0 question is a case in point.

Again: saying it's not a kernel problem isn't the
same as saying it's not a problem.

Commonly real-world usability and scalability depend
on "making the whole offer".  Users really aren't
interested in something that provides 60% or even 99%
of a working solution if the remainder is not readily
available.
