From: Dan Siemon <dan@coverfire.com>
Subject: Re: [RFC] batched tc to improve change throughput
Date: Sat, 12 Feb 2005 17:07:13 -0500
Message-ID: <1108246033.7554.18.camel@ganymede>
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
	 <1108134446.5523.22.camel@ganymede>
	 <1108215923.1126.132.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: hadi@cyberus.ca
In-Reply-To: <1108215923.1126.132.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2005-12-02 at 08:45 -0500, jamal wrote:
> On first impression, this looks very nice - I think you got the object
> hierachy figured etc; i will look closely later.
> What would be really interesting is to see (gulp) a SOAP/xml interface
> on top of this. Is this something you can do with those "bindings"?

Yes, a SOAP/XML-RPC interface should be quite possible.  This is one of
the main reasons I went to the trouble of creating the Mono bindings.  I
need to create some sort of XML interface to LQL in the next few weeks.

> It seems to me from a library perspective, youa nd Thomas may have to
> sync. And restricting to just QoS maybe be a limitation (netlink is the
> friend you are looking for; so from networking perspective, give them 
> GUI clikers ways to set routes, static IPSEC SAs etc). Oh and it would
> be interesting to have events (see that link come up down etc)

I named the project Linux QoS Library before I realized that interface
parameters etc could be manipulated via Netlink.  I have no intention of
limiting LQL to just QoS features.  Eventually I'll probably stop
referring to it as Linux QoS Library and just use LQL.

As for combining my work with Thomas, I'm certainly willing to discuss
it.

-- 
OpenPGP key: http://www.coverfire.com/files/pubkey.txt
Key fingerprint: FB0A 2D8A A1E9 11B6 6CA3  0C53 742A 9EA8 891C BD98
