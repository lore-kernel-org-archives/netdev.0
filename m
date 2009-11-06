From: md@Linux.IT (Marco d'Itri)
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Fri, 6 Nov 2009 09:49:21 +0100
Message-ID: <20091106084921.GA16700@bongo.bofh.it>
References: <EDA0A4495861324DA2618B4C45DCB3EE58954D@blrx3m08.blr.amer.dell.com> <20091013173638.GE1119@ldl.fc.hp.com> <20091016003245.GD29672@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE589579@blrx3m08.blr.amer.dell.com> <20091016152053.GA9862@ldl.fc.hp.com> <1255707193.2869.12.camel@achroite> <20091016214024.GA10091@ldl.fc.hp.com> <EDA0A4495861324DA2618B4C45DCB3EE5895AF@blrx3m08.blr.amer.dell.com> <4ADC906E.2050909@kadzban.is-a-geek.net> <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bryan@kadzban.is-a-geek.net, dannf@hp.com,
	bhutchings@solarflare.com, netdev@vger.kernel.org,
	linux-hotplug@vger.kernel.org, Matt_Domsch@Dell.com,
	Jordan_Hargrave@Dell.com, Charles_Rose@Dell.com,
	Sandeep_K_Shandilya@Dell.com
To: Narendra_K@Dell.com
Return-path: <linux-hotplug-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <EDA0A4495861324DA2618B4C45DCB3EE5896D2@blrx3m08.blr.amer.dell.com>
Sender: linux-hotplug-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Nov 04, Narendra_K@Dell.com wrote:

> SUBSYSTEM=="net", ACTION=="add", DRIVERS=="?*",
> ATTR{smbios_name}=="Embedded_NIC_1", ATTR{type}=="1", KERNEL=="eth*",
> NAME="eth0".
As a distribution developer I highly value solutions like this which do
not require patching every application which deals with interface names
and then teaching users about aliases which only work in some places and
are unknown to the kernel.

-- 
ciao,
Marco
