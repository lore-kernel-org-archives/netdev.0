From: "John S. Denker" <jsd@monmouth.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 07:58:33 -0400
Sender: linux-net-owner@vger.kernel.org
Message-ID: <3EE5C7E9.6090401@monmouth.com>
References: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi <hadi@shell.cyberus.ca>, ralph+d@istop.com,
	CIT/Paul <xerox@foonet.net>, 'Simon Kirby' <sim@netnation.com>,
	"'David S. Miller'" <davem@redhat.com>,
	"fw@deneb.enyo.de" <fw@deneb.enyo.de>,
	"netdev@oss.sgi.com" <netdev@oss.sgi.com>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Pekka Savola <pekkas@netcore.fi>
In-Reply-To: <Pine.LNX.4.44.0306101432530.21247-100000@netcore.fi>
List-Id: netdev.vger.kernel.org

On 06/10/2003 07:41 AM, Pekka Savola wrote:
> 
>>Typical packet is around 500 bytes
>>average. 
> 
> Not sure that's really the case.  I have the impression the traffic is 
> basically something like:
>  - close to 1500 bytes (data transfers)
>  - between 40-100 bytes (TCP acks, simple UDP requests, etc.)
>  - something in between

It helps to take a more sophisticated view of things.
In typical networks:
Most of the packet-count is to be found in small packets.
Most of the byte-count is to be found in large packets.

Some things (e.g. routing) depend mainly on the packet-count.
Other things (e.g. encryption, layer-1 hardware requirements,
memory bandwidth usage, ISP contracts) are sensitive to the
byte-count.

We shouldn't optimize one at the expense of the other.

