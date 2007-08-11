From: Jiri Kosina <jikos@jikos.cz>
Subject: Re: Weird network problems with 2.6.23-rc2
Date: Sat, 11 Aug 2007 23:55:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708112353410.3948@twin.jikos.cz>
References: <20070811083959.305b0421.shish@shishnet.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Shish <shish@shishnet.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764238AbXHKVzx@vger.kernel.org>
In-Reply-To: <20070811083959.305b0421.shish@shishnet.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 11 Aug 2007, Shish wrote:

> Something seems to have broken in 2.6.23-rc2, and I'm not sure what, or
> where I should look for further debugging. The info I have:
> 
> On my 2.6.23-rc2 desktop, things run fine.
> 
> On my test server, built from the same source tree, networking goes
> strange every few minutes, with the following symptoms:
> 
> o) running ping against the server, the first ping goes through;
> further pings go AWOL until about icmp_seq=30, when I get 4-5 icmp
> replies (marked as DUP!), then no pings for a while, then dups, and so
> on.
> 
> o) the server doesn't see ARP replies. According to tcpdump, the server
> will send eg "who has 192.168.0.2? tell 192.168.0.1"; the client in
> question will recieve the packet and send a response, but nothing shows
> up in the server-side tcpdump.
> 
> o) after a few minutes of random network troubles, everything will work
> fine again, (ping is normal, arp replies are seen, tcp sessions work)
> for a few minutes.
> 
> o) The server's dmesg shows lots of "short udp packet" messages
> 
> o) ifdown then ifup'ing the interfaces fixes things, temporarily.
> 
> Reverting to 2.6.22, everything seems to be running fine (but no lguest,
> which is what I came for :( )
> 
> I've also tried with the latest code from git, the behaviour is the same
> as 2.6.23-rc2.

This needs to go to netdev, CC added.

Also, git-bisect will help a lot here to find the commit which caused the 
regression you are seeing.

-- 
Jiri Kosina
