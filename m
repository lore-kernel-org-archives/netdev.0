From: "David S. Miller" <davem@redhat.com>
Subject: Re: Route cache performance under stress
Date: Tue, 10 Jun 2003 09:39:27 -0700 (PDT)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030610.093927.21906828.davem@redhat.com>
References: <Pine.LNX.4.51.0306092200150.28167@ns.istop.com>
	<20030610061010.Y36963@shell.cyberus.ca>
	<Pine.LNX.4.51.0306100828220.26498@ns.istop.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@shell.cyberus.ca, xerox@foonet.net, sim@netnation.com,
	fw@deneb.enyo.de, netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: ralph+d@istop.com, ralph@istop.com
In-Reply-To: <Pine.LNX.4.51.0306100828220.26498@ns.istop.com>
List-Id: netdev.vger.kernel.org

   From: Ralph Doncaster <ralph@istop.com>
   Date: Tue, 10 Jun 2003 09:10:43 -0400 (EDT)
   
   Yes, and it would be nice if you mentioned in your NAPI docs that
   people should use a tulip, tg3, or e1000 if they want it to work
   well.  In making your sales pitches for NAPI you made it sound like
   any high-performance card should do fine (i.e. anything but a Realtek).

The problems the 3c59x has is nothing to do with NAPI vs.
non-NAPI.  You're routing rate is limited by how much time
a PIO to the PCI device takes :)
