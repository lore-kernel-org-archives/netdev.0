From: "David S. Miller" <davem@redhat.com>
Subject: Re: Fragmentation Attack
Date: Sun, 8 Feb 2004 13:18:26 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040208131826.104eaef4.davem@redhat.com>
References: <20040208124528.2c667378.davem@redhat.com>
	<BC4C0264.E3F3%gandalf@digital.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Gandalf The White <gandalf@digital.net>
In-Reply-To: <BC4C0264.E3F3%gandalf@digital.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sun, 08 Feb 2004 15:12:36 -0600
Gandalf The White <gandalf@digital.net> wrote:

> The attack has ICMP, UDP and TCP.  If you were seeing a specific signature
> over and over again then I agree that it might be easy to block (depending
> on the firewall) ... But ... If someone were sending fragments destined for
> port 80 to your web server I don't see how you could differentiate between
> "real" fragments going to the web server and faked fragmentation requests.

In this day and age, and with all the headaches fragmentation causes
(either directly or indirectly via these resource consumption DoS's)
we may soon be reaching the point where only talking to sites doing
path-MTU discovery (yes, even for UDP) is a valid decision for a big
site.

This would solve the problem in a hurry.

For TCP I think people can do this today.  For UDP, what do you need fragmented
UDP for, DNS queries?  I think not for those types of usage, and even streaming
voice or whatever UDP uses chop up the datastream themselves spitting out a
non-fragmented time transmitted line of packets looking sort of ATM'ish.

Fragmented ICMP should just be blocked at firewall for people concerned about
this, I see no valid use of this.
