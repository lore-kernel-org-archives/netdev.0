From: "Karen Xie" <kxie@chelsio.com>
Subject: RE: [PATCH 2/3] cxgb4i: main driver files
Date: Tue, 13 Apr 2010 14:41:59 -0700
Message-ID: <8A71B368A89016469F72CD08050AD33407AC6530@maui.asicdesigners.com>
References: <1270728855-20951-1-git-send-email-rakesh@chelsio.com> <1270728855-20951-2-git-send-email-rakesh@chelsio.com> <1270728855-20951-3-git-send-email-rakesh@chelsio.com> <4BC4D711.5030802@cs.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Rakesh Ranjan" <rakesh@chelsio.com>, <netdev@vger.kernel.org>,
	<linux-scsi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<davem@davemloft.net>, <James.Bottomley@hansenpartnership.com>
To: "Mike Christie" <michaelc@cs.wisc.edu>,
	<open-iscsi@googlegroups.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-class: urn:content-classes:message
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Mike,

Yes, will do that for the next submission.

Thanks,
Karen

-----Original Message-----
From: Mike Christie [mailto:michaelc@cs.wisc.edu] 
Sent: Tuesday, April 13, 2010 1:42 PM
To: open-iscsi@googlegroups.com
Cc: Rakesh Ranjan; netdev@vger.kernel.org; linux-scsi@vger.kernel.org;
linux-kernel@vger.kernel.org; Karen Xie; davem@davemloft.net;
James.Bottomley@hansenpartnership.com
Subject: Re: [PATCH 2/3] cxgb4i: main driver files

On 04/08/2010 07:14 AM, Rakesh Ranjan wrote:
> +static inline int cxgb4i_ddp_gl_map(struct pci_dev *pdev,
> +				struct cxgb4i_gather_list *gl)
> +{
> +	int i;
> +
> +	for (i = 0; i<  gl->nelem; i++) {
> +		gl->phys_addr[i] = pci_map_page(pdev, gl->pages[i], 0,
> +						PAGE_SIZE,

Hey Rakesh,

I guess we are trying to move away from the pci mapping functions move 
to the dma ones. On your next submission, could you fix those up too?
