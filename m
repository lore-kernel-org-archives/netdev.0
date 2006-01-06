From: Patrick McHardy <kaber@trash.net>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Fri, 06 Jan 2006 23:22:34 +0100
Message-ID: <43BEEDAA.5040009@trash.net>
References: <1136541243.4037.18.camel@localhost>  <200601061200.59376.mbuesch@freenet.de>  <1136547494.7429.72.camel@localhost>  <200601061245.55978.mbuesch@freenet.de> <1136549423.7429.88.camel@localhost> <43BE6697.3030009@trash.net> <Pine.LNX.4.62.0601061414570.334@qynat.qvtvafvgr.pbz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marcel Holtmann <marcel@holtmann.org>,
	Michael Buesch <mbuesch@freenet.de>, jgarzik@pobox.com,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752482AbWAFWXO@vger.kernel.org>
To: David Lang <dlang@digitalinsight.com>
In-Reply-To: <Pine.LNX.4.62.0601061414570.334@qynat.qvtvafvgr.pbz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Lang wrote:
> On Fri, 6 Jan 2006, Patrick McHardy wrote:
> 
>> I think the main advantages of netlink over a character device is its
>> flexible format, which is easily extendable, and multicast capability,
>> which can be used to broadcast events and configuration changes. Its
>> also good to have all the net stuff accessible in a uniform way.
> 
> 
> character devices are far easier to script. this really sounds like the 
> type of configuration stuff that sysfs was designed for. can we avoid 
> yet another configuration tool that's required?

I think its not just configuration but also event handling
for associating, link layer authentication, ..., which is
not something handled by scripts but by some daemon. It might
also want to set up routes or ip addresses which is done using
netlink anyway.
