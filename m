From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: net/ipv6/exthdrs.c
Date: Tue, 18 Jun 2002 15:00:22 +0300 (EEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0206181458340.26140-100000@netcore.fi>
References: <20020618135149.A24751@sch.bme.hu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Andras Kis-Szabo <kisza@securityaudit.hu>
In-Reply-To: <20020618135149.A24751@sch.bme.hu>
List-Id: netdev.vger.kernel.org

On Tue, 18 Jun 2002, Andras Kis-Szabo wrote:
> Is there any plan to add the ESP header to the ipv6_ext_hdr() function (as a
> known header)?
> (It requires changes in this file and in the icmp.c at the first round.)

Quickly looking at it, I don't know if adding it would help any (on the 
countrary).

The code seems to be used mainly to skip over extension headers
(forbidden, strictly speaking) when generating ICMP messages; in the case 
of ESP, the rest of the payload should be encrypted so adding it to the 
list would probably not change anything?

-- 
Pekka Savola                 "Tell me of difficulties surmounted,
Netcore Oy                   not those you stumble over and fall"
Systems. Networks. Security.  -- Robert Jordan: A Crown of Swords
