From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH 2/3] xgbe: switch to pci_irq_alloc_vectors
Date: Wed, 11 Jan 2017 10:46:45 -0600
Message-ID: <c3f96e57-0a22-99dd-ca48-b0b84913e4df@amd.com>
References: <1483994260-19797-1-git-send-email-hch@lst.de>
 <1483994260-19797-3-git-send-email-hch@lst.de>
 <11ed330c-84e9-79e9-7945-ca17a497359c@amd.com> <20170111090357.GB7350@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-pci@vger.kernel.org>,
        Mauro Carvalho Chehab <mchehab@s-opensource.com>,
        <netdev@vger.kernel.org>, <linux-media@vger.kernel.org>
To: Christoph Hellwig <hch@lst.de>
Return-path: <linux-media-owner@vger.kernel.org>
In-Reply-To: <20170111090357.GB7350@lst.de>
Sender: linux-media-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/11/2017 3:03 AM, Christoph Hellwig wrote:
> On Tue, Jan 10, 2017 at 12:40:10PM -0600, Tom Lendacky wrote:
>> On 1/9/2017 2:37 PM, Christoph Hellwig wrote:
>>> The newly added xgbe drivers uses the deprecated pci_enable_msi_exact
>>> and pci_enable_msix_range interfaces.  Switch it to use
>>> pci_irq_alloc_vectors instead.
>>
>> I was just working on switching over to this API with some additional
>> changes / simplification.  I'm ok with using this patch so that you get
>> the API removal accomplished.  Going through the PCI tree just means
>> it will probably be easier for me to hold off on the additional changes
>> I wanted to make until later.
> 
> Hi Tom,

Hi Christoph,

> 
> if you have a better patch I'd be more than happy to use that one instead,
> this one was intended as a stupid search and replace.  The important
> part for me is to get the two conversions and the interface removal
> in together.

That sounds good, I'll send the patch to you in a separate email for use
in your series.

Thanks,
Tom

> 
> E.g. I've alreayd wondered why the driver requires the exact vector
> number for MSI and a variable one for MSI-X, and there certainly is
> all kinds of opportunity for cosmetic cleanup.
> 
