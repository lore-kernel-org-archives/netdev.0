From: "John Stoffel" <john@stoffel.org>
Subject: Re: ipw2100: firmware problem
Date: Fri, 10 Jun 2005 09:00:56 -0400
Message-ID: <17065.36616.214742.580727@smtp.charter.net>
References: <200506090909.55889.vda@ilport.com.ua>
	<20050608.231657.59660080.davem@davemloft.net>
	<20050609104205.GD3169@elf.ucw.cz>
	<20050609.125324.88476545.davem@davemloft.net>
	<42A8AE2A.4080104@linux.intel.com>
	<42A8F758.2060008@pobox.com>
	<42A8FF03.3010508@linuxwireless.org>
	<20050610090022.GF4173@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alejandro Bonilla <abonilla@linuxwireless.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	James Ketrenos <jketreno@linux.intel.com>,
	"David S. Miller" <davem@davemloft.net>, vda@ilport.com.ua,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org,
	ipw2100-admin@linux.intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261238AbVFJNBD@vger.kernel.org>
To: Pavel Machek <pavel@ucw.cz>
In-Reply-To: <20050610090022.GF4173@elf.ucw.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I'd like to chime in here and say that from my point of view, not
enabling the wireless network adaptor until asked by userspace is the
way to go. 

It reduces power requirements, and it pushes the configuration details
out to userspace, where they can be handled according to the policy
setup by the distro/user.

Having my latop bootup and turn on the wireless card and join an AP
without my explicity asking is a bad thing to have happen.  

John
