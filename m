From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 21/37] drivers/ata: use .dev.of_node instead of .node
 in struct of_device
Date: Thu, 11 Mar 2010 13:36:55 -0500
Message-ID: <4B993847.3030100@pobox.com>
References: <20100311174830.4824.19820.stgit@angua> <20100311180543.4824.70491.stgit@angua> <4B9936F2.3020105@ru.mvista.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Grant Likely <grant.likely@secretlab.ca>, monstr@monstr.eu,
	gregkh@suse.de, benh@kernel.crashing.org,
	akpm@linux-foundation.org, davem@davemloft.net,
	sfr@canb.auug.org.au, ben-linux@fluff.org, dwmw2@infradead.org,
	jeremy.kerr@canonical.com, James.Bottomley@suse.de,
	broonie@opensource.wolfsonmicro.com,
	microblaze-uclinux@itee.uq.edu.au, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, sparclinux@vger.kernel.org,
	linux-ide@vger.kernel.org, netdev@vger.kernel.org,
	linux-i2c@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linux-scsi@vger.kernel.org, alsa-devel@alsa-project.org
To: Sergei Shtylyov <sshtylyov@mvista.com>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <4B9936F2.3020105@ru.mvista.com>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2010 01:31 PM, Sergei Shtylyov wrote:
> Hello.
>
> Grant Likely wrote:
>
>> .node is being removed
>>
>> Signed-off-by: Grant Likely <grant.likely@secretlab.ca>
>> ---
>>
>> drivers/ata/pata_macio.c | 2 +-
>> drivers/ata/pata_of_platform.c | 2 +-
>> drivers/ide/pmac.c | 10 +++++-----
>> 3 files changed, 7 insertions(+), 7 deletions(-)
>
> Should probably have been 2 patches instead of one, as drivers/ata/ and
> drivers/ide/ are different subsystems...

Possibly, but these patches should go in via the OF tree anyway, so 
collecting ACKs should be sufficient.

	Jeff



