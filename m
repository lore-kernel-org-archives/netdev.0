From: Sandy Harris <sandy@storm.ca>
Subject: Re: [CryptoAPI-devel] Re: [Design] [PATCH] USAGI IPsec
Date: Mon, 21 Oct 2002 19:27:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DB4B77B.90607@storm.ca>
References: <m3k7kpjt7c.wl@karaba.org>  <3DB41338.3070502@storm.ca> 	<1035168066.4817.1.camel@rth.ninka.net> <1035185654.21824.11.camel@janus.txd.hvrlab.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@rth.ninka.net>,
   Mitsuru KANDA
 <mk@linux-ipv6.org>, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, cryptoapi-devel@kerneli.org, design@lists.freeswan.org,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Valerio Riedel <hvr@hvrlab.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Valerio Riedel wrote:

>On Mon, 2002-10-21 at 04:41, David S. Miller wrote:
>
>  
>
>>A completely new CryptoAPI subsystem has been implemented so that
>>full lists of page vectors can be passed into the ciphers, which is
>>necessary for a clean IPSEC implementation.
>>    
>>
>
>oh... nice to learn about your plans (so late) at all ;-)
>
>well, it would be cool if you'd cooperate (or at least share
>information) with us (the official cryptoapi project ;-), as we're open
>for the design requirements of the next generation cryptoapi...
>
>...otherwise this may render the kerneli.org/cryptoapi effort completely
>useless :-/ ...of course, if it's your long term goal to take the
>cryptoapi development away from kerneli.org, I'd like to know too ;-)
>
>regards,
>  
>
I think the long term goal should be to get good crypto, at least IPsec 
and disk encryption,
into the mainline, standard Linux kernel. Also ipv6 support. Projects 
like FreeS/WAN, USAGI
and cryptoapi seem necessary for getting the work done in the first 
place, but eventually you
want to do away with patch sets and just have all the good stuff built 
in to the kernel.

One payoff is integration. As I understand it, a current fully-patched 
kernel has either MD-5
or SHA-1 in the /dev/random driver, both in FreeS/WAN, and possibly both 
of those plus a
few other hashes in the CryptoAPI stuff. This is silly. The obvious fix 
is for everyone to use
the CryptoAPI hashes and ciphers.

However, crypto is a special case. The US government (among others) has 
a long history
of  restricting it and, much as we would like to see good crypto in the 
standard kernel,
there's a good case for being very careful to keep code out of their 
clutches.

My suggestion would be that the standard kernel incorporate only one 
good hash
and one good cipher, specifically AES and SHA-256 since (last I looked) 
those
were en route to becoming requirements for IPsec. Let the FreeS/WAN and
CryptoAPI folk -- outside the US -- maintain the other ciphers and 
hashes. That
way we have a fallback position if the US goes back to being viciously 
restrictive.
