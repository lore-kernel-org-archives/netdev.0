From: Gandalf The White <gandalf@digital.net>
Subject: Re: Fragmentation Attack
Date: Sun, 08 Feb 2004 15:12:36 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <BC4C0264.E3F3%gandalf@digital.net>
References: <20040208124528.2c667378.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Linux IPStack <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040208124528.2c667378.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Greetings and Salutations:

On 2/8/04 2:45 PM, "David S. Miller" <davem@redhat.com> wrote:
> On Sat, 07 Feb 2004 12:00:42 -0600
> Gandalf The White <gandalf@digital.net> wrote:
>> The requirements of the attack (from the perspective of the paper I wrote)
>> was that you had taken over 20 cable modem computers.  From this viewpoint
>> this could (of course) produce the required number of packets IMHO.
>> 
>> Of course you could also clog up the bandwidth of just about any destination
>> network with this requirement, but that is a different DoS.
> Yes, but this very fact makes the "DoS" much much less interesting.
> If I can clog your link anyways with arbitrary traffic, who cares
> what it does as a second order effect, the machine is made unreachable
> and unusable either way.

Exactly.  So I was discounting the "clog your connection" attack.  What I
was looking at is if someone has a fast machine that they can send a
regulated amount of packets to and test out the fragment attack that would
be good.  I suspect that this attack would still spike the CPU on a machine
at a relatively low (a few hundred) packets per second rate.  On a web
server or other Internet Facing machine that has a decent load this could be
enough CPU overhead to create a DoS.

> Also, these half-complete ICMP packets are really super easy to create
> firewall rules for to block them at ingress of a major site.

The attack has ICMP, UDP and TCP.  If you were seeing a specific signature
over and over again then I agree that it might be easy to block (depending
on the firewall) ... But ... If someone were sending fragments destined for
port 80 to your web server I don't see how you could differentiate between
"real" fragments going to the web server and faked fragmentation requests.


Ken

---------------------------------------------------------------
Do not meddle in the affairs of wizards for they are subtle and
quick to anger.
Ken Hollis - Gandalf The White - gandalf@digital.net - O- TINLC
WWW Page - http://digital.net/~gandalf/
Trace E-Mail forgery - http://digital.net/~gandalf/spamfaq.html
Trolls crossposts - http://digital.net/~gandalf/trollfaq.html
