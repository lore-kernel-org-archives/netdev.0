From: Dan Siemon <dan@coverfire.com>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Fri, 11 Feb 2005 10:07:26 -0500
Message-ID: <1108134446.5523.22.camel@ganymede>
References: <20050117165626.GE26856@postel.suug.ch>
	 <1106002197.1046.19.camel@jzny.localdomain>
	 <20050118134406.GR26856@postel.suug.ch>
	 <1106058592.1035.95.camel@jzny.localdomain>
	 <20050118145830.GS26856@postel.suug.ch>
	 <1106144009.1047.989.camel@jzny.localdomain>
	 <20050119165421.GB26856@postel.suug.ch>
	 <1106232168.1041.125.camel@jzny.localdomain>
	 <20050120153559.GG26856@postel.suug.ch>
	 <1106576005.1652.1292.camel@jzny.localdomain>
	 <20050124150634.GT23931@postel.suug.ch>
	 <1106747313.1107.7.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca
To: netdev@oss.sgi.com
In-Reply-To: <1106747313.1107.7.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2005-26-01 at 08:48 -0500, jamal wrote:
> Your call really - you are the one who is going to maintain it;->
> As for ease of use and avoiding users from knowing details of how
> tlvs are put together etc - i think it doesnt matter how thats done
> underneath the hood; it is still doable on top of current libnetlink. In
> other words whats required, IMO, is something that hides netlink totaly
> so that the programmer/user doesnt even get to see TLVs.

(Sorry to join this thread so late.)

I'd like to make a little plug for my Linux QoS Library (LQL) [1]
project.  LQL provides an abstraction of the kernel QoS features.  Full
API documentation is available from the website.

I already have working bindings for one high level language (C# on Mono)
[2]. Creating bindings for Python, Perl etc should be quite easy.
Someone recently emailed me about starting work on Perl bindings.

There is still lots of work to do.  Support for more QDiscs and
classifiers is needed and the socket handling code needs a rewrite to
better handle errors.  Work continues and these things will be fixed.

[1] - http://www.coverfire.com/lql/
[2] - http://www.coverfire.com/lql-sharp/

-- 
OpenPGP key: http://www.coverfire.com/files/pubkey.txt
Key fingerprint: FB0A 2D8A A1E9 11B6 6CA3  0C53 742A 9EA8 891C BD98
