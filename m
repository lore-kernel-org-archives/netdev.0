From: Santosh Shilimkar <santosh.shilimkar@ti.com>
Subject: Re: [PATCH v2 0/3] net: Add Keystone NetCP ethernet driver support
Date: Tue, 9 Sep 2014 11:19:54 -0400
Message-ID: <540F1A9A.1020309@ti.com>
References: <1408115562-22487-1-git-send-email-santosh.shilimkar@ti.com> <20140821.163612.282672926741753926.davem@davemloft.net> <53F79DC5.8030003@ti.com> <540DC00F.1080103@ti.com> <540EE809.9020901@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <robh+dt@kernel.org>,
	<grant.likely@linaro.org>, <devicetree@vger.kernel.org>,
	<sandeep_n@ti.com>, Benjamin LaHaise <bcrl@kvack.org>,
	shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <540EE809.9020901@mojatatu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 09 September 2014 07:44 AM, Jamal Hadi Salim wrote:
> On 09/08/14 10:41, Santosh Shilimkar wrote:
> 
>>> The NetCP plugin module infrastructure use all the standard kernel
>>> infrastructure and its very tiny.
> 
> So i found this manual here:
> http://www.silica.com/fileadmin/02_Products/Productdetails/Texas_Instruments/SILICA_TI_66AK2E05-ds.pdf
> 
> Glad there is an open document!
> There are a couple of ethernet switch chips I can spot there.
> 
All the documentation is open including packet accelerator offload
in ti.com.

> Can i control those with "bridge" or say "brctl" utilities?
> 
> I can see the bridge ports are exposed and i should be able to
> control them via ifconfig or ip link. Thats what "standard
> kernel infrastructure" means. Magic hidden in a driver is
> not.
> 
There is nothing magic hidden in the driver. The bridge ports
are exposed as standard network interfaces. Currently the
drivers don't support bridge offload functionality and
the bridging is disabled in the switch by default. 

> Take a look at recent netconf discussion (as well as earlier
> referenced discussions):
> http://vger.kernel.org/netconf-nf-offload.pdf
> 
> Maybe we can help providing you some direction?
> The problem is it doesnt seem that the offload specs for
> those other pieces are open? e.g how do i add an entry
> to the L2 switch?
> 
We got such requests from customers but couldn't
support it for Linux. We are also looking for such
support and any direction are welcome. Your slide
deck seems to capture the key topics like L2/IPSEC
offload which we are also interested to hear.

Just to be clear, your point was about L2 switch offload
which the driver don't support at the moment. It might confuse
others. The driver doesn't implements anything non-standard.

Regards,
Santosh
