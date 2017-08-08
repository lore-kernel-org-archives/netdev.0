From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH V3 net-next 03/21] net-next/hinic: Initialize api cmd
 resources
Date: Tue, 8 Aug 2017 19:23:32 +0300
Message-ID: <912a2667-8b20-cbc2-4c32-7d34bfb6bb9b@huawei.com>
References: <cover.1501752425.git.aviad.krawczyk@huawei.com>
 <18d3bfccc0eb9c7da53075c6fe2ba9aa583e0bff.1501752425.git.aviad.krawczyk@huawei.com>
 <20170803.153513.1478323340993171697.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
        <bc.y@huawei.com>, <victor.gissin@huawei.com>,
        <zhaochen6@huawei.com>, <tony.qu@huawei.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170803.153513.1478323340993171697.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David,

Is it a new rule?

We can fix it, but I can look over the Linux Kernel source and there are
a lot of examples that have the same problem. I can see even code that inserted
to 4.10 with the same problem.

Thanks for your time and review,
Aviad

On 8/4/2017 1:35 AM, David Miller wrote:
> From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
> Date: Thu, 3 Aug 2017 17:54:09 +0800
> 
>> +static int alloc_cmd_buf(struct hinic_api_cmd_chain *chain,
>> +			 struct hinic_api_cmd_cell *cell, int cell_idx)
>> +{
>> +	struct hinic_hwif *hwif = chain->hwif;
>> +	struct pci_dev *pdev = hwif->pdev;
>> +	struct hinic_api_cmd_cell_ctxt *cell_ctxt;
>> +	dma_addr_t cmd_paddr;
>> +	u8 *cmd_vaddr;
>> +	int err = 0;
> 
> Order local variables from longest to shortest line.
> 
>> +static int api_cmd_create_cell(struct hinic_api_cmd_chain *chain,
>> +			       int cell_idx,
>> +			       struct hinic_api_cmd_cell *pre_node,
>> +			       struct hinic_api_cmd_cell **node_vaddr)
>> +{
>> +	struct hinic_hwif *hwif = chain->hwif;
>> +	struct pci_dev *pdev = hwif->pdev;
>> +	struct hinic_api_cmd_cell_ctxt *cell_ctxt;
>> +	struct hinic_api_cmd_cell *node;
>> +	dma_addr_t node_paddr;
>> +	int err;
> 
> Likewise.
>> +static void api_cmd_destroy_cell(struct hinic_api_cmd_chain *chain,
>> +				 int cell_idx)
>> +{
>> +	struct hinic_hwif *hwif = chain->hwif;
>> +	struct pci_dev *pdev = hwif->pdev;
>> +	struct hinic_api_cmd_cell_ctxt *cell_ctxt;
>> +	struct hinic_api_cmd_cell *node;
>> +	dma_addr_t node_paddr;
>> +	size_t node_size;
> 
> Likewise.
> 
> etc. etc. etc.
> 
> Please audit your entire submission for this problem.
> 
> Thanks.
> 
> .
> 
