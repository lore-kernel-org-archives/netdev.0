From: Mike Christie <michaelc@cs.wisc.edu>
Subject: Re: [PATCH 2/3] cxgb4i: main driver files
Date: Tue, 13 Apr 2010 15:41:53 -0500
Message-ID: <4BC4D711.5030802@cs.wisc.edu>
References: <1270728855-20951-1-git-send-email-rakesh@chelsio.com> <1270728855-20951-2-git-send-email-rakesh@chelsio.com> <1270728855-20951-3-git-send-email-rakesh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rakesh Ranjan <rakesh@chelsio.com>, netdev@vger.kernel.org,
	linux-scsi@vger.kernel.org, linux-kernel@vger.kernel.org,
	kxie@chelsio.com, davem@davemloft.net,
	James.Bottomley@hansenpartnership.com
To: open-iscsi@googlegroups.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1270728855-20951-3-git-send-email-rakesh@chelsio.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
