From: Mark Jackson <mpfj-list@newflow.co.uk>
Subject: Re: [PATCH 0/3] Dual EMAC mode implementation of CPSW
Date: Tue, 23 Apr 2013 06:11:06 +0100
Message-ID: <517617EA.7050807@newflow.co.uk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com> <516B0098.4040809@mimc.co.uk> <516C33D2.4050105@ti.com> <516C38B9.50904@mimc.co.uk> <516C3A0D.70903@ti.com> <517018E6.6080108@newflow.co.uk> <51754427.7000908@newflow.co.uk> <51756CF2.4050602@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org
To: Mugunthan V N <mugunthanvnm@ti.com>,
	systemprogrammierung.brunner@gmail.com
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <51756CF2.4050602@ti.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 22/04/13 18:01, Mugunthan V N wrote:
> On 4/22/2013 7:37 PM, Mark Jackson wrote:
>> Mugunthan
>>
>> Can you confirm that I'm actually trying to achieve the right thing ?
>>
>> I have all along assumed that Dual EMAC mode would simply provide the
>> kernel will a pair of independent Ethernet ports.
> Yes, it will provide two network interfaces for ex eth0 and eth1
>> All I am trying to do is to get both Ethernet ports working so I can
>> have one port on (say) 10.0.x.x and the other on (say) 10.1.x.x
> This is perfectly correct
>> But there is all this reference to VLANs(in the source code and the TRM)
>> ... I have not setup any VLANs.  Do I need to ?  If so, how ?
> No need to setup any VLAN. VLAN are used to segregate the
> two down stream ports and it will be taken care by the driver

Mugunthan

I now have this all working, thanks to Markus Brunner who spotted that
the CPSW_VLAN_AWARE bit is being incorrectly set rather than cleared in
cpsw_init_host_port().

I think he will be posting a patch soon.

Regards
Mark J.
