From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: A new 10GB Ethernet Driver by Chelsio Communications
Date: Fri, 11 Mar 2005 23:49:41 -0500
Message-ID: <423274E5.4060804@pobox.com>
References: <Pine.LNX.4.58.0503110356340.14213@server.graphe.net> <20050311112132.6a3a3b49.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, mark@chelsio.com, netdev@oss.sgi.com
To: Andrew Morton <akpm@osdl.org>,
	Christoph Lameter <christoph@graphe.net>
In-Reply-To: <20050311112132.6a3a3b49.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> Christoph Lameter <christoph@graphe.net> wrote:
> 
>>A Linux driver for the Chelsio 10Gb Ethernet Network Controller by
>> Chelsio (http://www.chelsio.com). This driver supports the Chelsio N210
>> NIC and is backward compatible with the Chelsio N110 model 10Gb NICs.
> 
> 
> Thanks, Christoph.
> 
> The 400k patch was too large for the vger email server so I have uploaded it to
> 
>  http://www.zip.com.au/~akpm/linux/patches/stuff/a-new-10gb-ethernet-driver-by-chelsio-communications.patch

step 1:  kill all the OS wrappers.

And do you really need hooks for multiple MACs, when only one MAC is 
really supported?  Typically these hooks are at a higher level anyway -- 
struct net_device.

	Jeff
