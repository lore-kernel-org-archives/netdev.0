From: Sven Schuster <schuster.sven@gmx.de>
Subject: Re: Linux <---> Unixware slow networking with e100
Date: Sun, 09 Nov 2003 15:43:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FAE528B.6090002@gmx.de>
References: <3FA9F8D5.9020601@gmx.de> <20031109123435.B1282@sygehus.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rask Ingemann Lambertsen <rask@sygehus.dk>
In-Reply-To: <20031109123435.B1282@sygehus.dk>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rask Ingemann Lambertsen wrote:

>On Thu, Nov 06, 2003 at 08:31:33AM +0100, Sven Schuster wrote:
>
>
>>But when _receiving_ data from one of the unixware machines, we
>>just get a few kB/s, max. about 100 kB/s. When _sending_ data to
>>a unixware machine, the transfer rate is fine too. Are there any
>>known issues between linux and unixware (except the SCO thing
>>;-) ) ??
>>
>
>Run tcpdump and see what the window sizes are when sending data from
>Unixware to Linux.
>
This actually seems to be a problem with either a switch in the network or
with the onboard intel network card. I think it's one of the  switches, or
maybe the combination of those (one Planet FN-SW102 100 Mbit and one 
Foundry
B15000 with the ports of our machines running at 100 Mbit), because we have
the same slow transfer rates in this network from unixware to unixware. 
I did
some tests yesterday directly from a redhat AS 2.1 to a unixware machine 
via
cat. 7 crossover, and I didn't have any problems. And over a Planet switch
(100 Mbit) there also were no problems.

But thanks for your tip!! I'll get back and report what the issue was 
for the
archives.

Sven
