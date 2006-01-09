From: Ingo Oeser <netdev@axxeo.de>
Subject: Re: [Bcm43xx-dev] [Fwd: State of the Union: Wireless]
Date: Mon, 9 Jan 2006 19:24:26 +0100
Message-ID: <200601091924.26575.netdev@axxeo.de>
References: <1136549423.7429.88.camel@localhost> <Pine.LNX.4.62.0601061414570.334@qynat.qvtvafvgr.pbz> <20060106.141836.41371212.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: dlang@digitalinsight.com, kaber@trash.net, marcel@holtmann.org,
	mbuesch@freenet.de, jgarzik@pobox.com,
	bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030226AbWAISYg@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060106.141836.41371212.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: David Lang <dlang@digitalinsight.com>
> Date: Fri, 6 Jan 2006 14:16:17 -0800 (PST)
> 
> > character devices are far easier to script. this really sounds like the 
> > type of configuration stuff that sysfs was designed for. can we avoid yet 
> > another configuration tool that's required?
> 
> netlink is being recommended exactly because it can result
> in only needing one tool for everything

Yes, iproute2 rocks!

I recently discovered that it can do "xfrm" stuff and was amazed to
see that the developer(s) had a big clue about what we like to
see (and what is human readable), if we type "ip xfrm state" 
and "ip xfrm policy" as opposed to "setkey -D" and "setkey -PD".

So I can only hope that netlink and iproute will be chosen as a way
to represent it to the user, just because of the clueful developers of
iproute2.


Regards

Ingo Oeser
