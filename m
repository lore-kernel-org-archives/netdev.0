From: Jamie Lokier <jamie@shareable.org>
Subject: Re: preliminary conclusions regarding window size issues
Date: Thu, 8 Jul 2004 02:44:43 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040708014443.GE17266@mail.shareable.org>
References: <20040707232757.GA14471@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: bert hubert <ahu@ds9a.nl>, "David S. Miller" <davem@redhat.com>,
        Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, linux-kernel@vger.kernel.org,
        ALESSANDRO.SUARDI@ORACLE.COM
Content-Disposition: inline
In-Reply-To: <20040707232757.GA14471@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

bert hubert wrote:
> Alessandro never sees these packets!
...
> My current feeling is that some kind of QoS device is interfering,
> and that the 'wscale gets stuffed' theory is wrong in this case.
> 
> I recall that 'Packeteer' QoS devices try to mess with windows.

It's a bit fiddly to arrange, but can you repeat the test and
artificially lower the TTL for these packets which disappear?

An iptable mangle rule would do the trick -- mangle the TTL only on
packets which match this point in the trace.

The idea is to reduce the TTL like traceroute does, so you can see
which hop is causing these packets to disappear -- perhaps it'll stand
out proudly as a QoS device which can be named, blamed and shamed.

-- Jamie
