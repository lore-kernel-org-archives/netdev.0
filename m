From: "David S. Miller" <davem@redhat.com>
Subject: Re: VLAN patches
Date: Sun, 06 Oct 2002 19:46:54 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021006.194654.35505461.davem@redhat.com>
References: <20021005.220549.15266753.davem@redhat.com>
	<Pine.GSO.4.30.0210061839210.1861-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, Bjorn.Andersson@ebc.ericsson.se,
   netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <Pine.GSO.4.30.0210061839210.1861-100000@shell.cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: jamal <hadi@cyberus.ca>
   Date: Sun, 6 Oct 2002 18:47:50 -0400 (EDT)
   
   A packet with VLANid 0 and an 802.1p tag > 0 is legal. I
   think its known as a "priority tagged" packet (not 100% sure
   about the term). Therefore VLANid 0 MUST be accepted and ability to send
   it should be there.

Great, I stand corrected, please send me a patch which therefore
accepts VID 0 on create and destroy.

   BTW, what about VLANid 0xFFF?

Your guess is as good as mine ;-)
