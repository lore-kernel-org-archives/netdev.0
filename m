From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [REGRESSION, bisect] net: ipv6: unregister_netdevice: waiting for
 lo to become free. Usage count = 2
Date: Wed, 2 Mar 2016 13:00:21 -0800
Message-ID: <56D75465.4060705@cumulusnetworks.com>
References: <6c735168f53548a39bd21e6e9857f512@HKXPR3004MB0088.064d.mgd.msft.net>
 <20160301200749.GA1611@hudson.localdomain>
 <20160302203150.GA2045@hudson.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeremiah Mahler <jmmahler@gmail.com>,
	Dexuan Cui <decui@microsoft.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160302203150.GA2045@hudson.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 3/2/16 12:31 PM, Jeremiah Mahler wrote:
>> On Tue, Mar 01, 2016 at 08:11:54AM +0000, Dexuan Cui wrote:
>>> Hi, I got this line every 10 seconds with today's linux-next in a Hyper-V guest, even
>>> when I didn't configure any NIC for the guest:
>>>
>>> [   72.604249] unregister_netdevice: waiting for lo to become free. Usage count = 2
>>> [   82.708170] unregister_netdevice: waiting for lo to become free. Usage count = 2
>>> [   92.788079] unregister_netdevice: waiting for lo to become free. Usage count = 2
>>> [  102.808132] unregister_netdevice: waiting for lo to become free. Usage count = 2
>>> [  112.928166] unregister_netdevice: waiting for lo to become free. Usage count = 2
>>> [  122.952069] unregister_netdevice: waiting for lo to become free. Usage count = 2
>>>
>>> I don't think this is related to the underlying host, since it's related to "lo".

This should fix it:
     https://patchwork.ozlabs.org/patch/591102/


David
