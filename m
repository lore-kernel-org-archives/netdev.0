From: Albert Pretorius <albertpretorius@yahoo.co.uk>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Thu, 2 Dec 2010 07:45:48 +0000 (GMT)
Message-ID: <616589.97517.qm@web29017.mail.ird.yahoo.com>
References: <4CF604DB.8000302@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org,
	"yoshfuji@linux-ipv6.org >> YOSHIFUJI Hideaki"
	<yoshfuji@linux-ipv6.org>, David Miller <davem@davemloft.net>,
	pekkas@netcore.fi, jmorris@namei.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nm18.bullet.mail.ird.yahoo.com ([77.238.189.71]:20485 "HELO
	nm18.bullet.mail.ird.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752687Ab0LBHpu convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 02:45:50 -0500
In-Reply-To: <4CF604DB.8000302@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

--- On Wed, 1/12/10, Shan Wei <shanwei@cn.fujitsu.com> wrote:
> I think it make nonsense to translate data between loopback
> device and other e.g. eth0 device in same machine.

I agree, RFC4291 makes it clear for IPV6 that no interface should accept traffic from loopback, I should not have tried to make it behave like IPV4.
I can not find an equivalent statement for IPV4 though, all I could find is this from RFC3330:

   127.0.0.0/8 - This block is assigned for use as the Internet host
   loopback address.  A datagram sent by a higher level protocol to an
   address anywhere within this block should loop back inside the host.
   This is ordinarily implemented using only 127.0.0.1/32 for loopback,
   but no addresses within this block should ever appear on any network
   anywhere [RFC1700, page 5].

Do you perhaps know?
thank you,
Albert Pretorius


      
