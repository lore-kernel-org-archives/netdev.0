From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [REGRESSION, bisect] net: ipv6: unregister_netdevice: waiting for
 lo to become free. Usage count = 2
Date: Thu, 3 Mar 2016 05:25:58 +0000
Message-ID: <BLUPR03MB1410B44AE0B2E11F4930D620BFBD0@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <6c735168f53548a39bd21e6e9857f512@HKXPR3004MB0088.064d.mgd.msft.net>
 <20160301200749.GA1611@hudson.localdomain>
 <20160302203150.GA2045@hudson.localdomain>
 <56D75465.4060705@cumulusnetworks.com>
 <20160303012324.GA1882@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"David S. Miller" <davem@davemloft.net>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jeremiah Mahler <jmmahler@gmail.com>,
	David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0114.outbound.protection.outlook.com ([207.46.100.114]:41238
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751091AbcCCF0C convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 00:26:02 -0500
In-Reply-To: <20160303012324.GA1882@hudson.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi David,
> On Wed, Mar 02, 2016 at 01:00:21PM -0800, David Ahern wrote:
> > On 3/2/16 12:31 PM, Jeremiah Mahler wrote:
> > >>On Tue, Mar 01, 2016 at 08:11:54AM +0000, Dexuan Cui wrote:
> > >>>Hi, I got this line every 10 seconds with today's linux-next in a Hyper-V
> guest, even
> > >>>when I didn't configure any NIC for the guest:
> > >>>
> > >>>[   72.604249] unregister_netdevice: waiting for lo to become free. Usage
> count = 2
> > >>>[   82.708170] unregister_netdevice: waiting for lo to become free. Usage
> count = 2
> > >>>[   92.788079] unregister_netdevice: waiting for lo to become free. Usage
> count = 2
> > >>>[  102.808132] unregister_netdevice: waiting for lo to become free. Usage
> count = 2
> > >>>[  112.928166] unregister_netdevice: waiting for lo to become free. Usage
> count = 2
> > >>>[  122.952069] unregister_netdevice: waiting for lo to become free. Usage
> count = 2
> > >>>
> > >>>I don't think this is related to the underlying host, since it's related to "lo".
> >
> > This should fix it:
> > https://patchwork.ozlabs.org/patch/591102/
> 
> > David
> 
> That patch fixes the problem on my machine.
> Thanks for the quick fix :-)
> 
> - Jeremiah Mahler

This works for me too! Thanks!

Thanks,
-- Dexuan
