From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: sungem - ifconfig eth0 mtu 1300 -> oops
Date: Tue, 22 Jun 2004 11:04:59 -0400
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40D84A9B.8010503@pobox.com>
References: <20040621141144.119be627.davem@redhat.com> <40D847E3.2080109@nortelnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>, kernel@nn7.de,
	linux-kernel@vger.kernel.org, benh@kernel.crashing.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org-S264898AbUFVPZJ@vger.kernel.org>
To: Chris Friesen <cfriesen@nortelnetworks.com>
In-Reply-To: <40D847E3.2080109@nortelnetworks.com>
List-Id: netdev.vger.kernel.org

Chris Friesen wrote:
> Just a quick question.  Does the sungem chip support jumbo frames?  I'd 
> like to use MTU of 9000 to make large local transfers more efficient, 
> but it didn't seem to work last time I checked.


Are you 100% certain you configured the other side to support jumbo?

Jumbo frames are non-standard, and sometimes require configuring MTU on 
the switch or remote network card (if directly connected).

	Jeff
