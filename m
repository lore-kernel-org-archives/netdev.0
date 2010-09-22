From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 2/2] siw: Add support for CRC32C offload instruction
	using libcrypto crc32c-intel
Date: Wed, 22 Sep 2010 13:38:21 -0700
Message-ID: <1285187901.1849.85.camel@haakon2.linux-iscsi.org>
References: <1285187425-10950-1-git-send-email-nab@linux-iscsi.org>
	 <4C9A698B.90806@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	linux-rdma <linux-rdma@vger.kernel.org>,
	Bernard Metzler <BMT@zurich.ibm.com>,
	David Miller <davem@davemloft.net>,
	Matthew Wilcox <willy@linux.intel.com>,
	Roland Dreier <rdreier@cisco.com>
To: Andi Kleen <ak@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C9A698B.90806@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-09-22 at 22:39 +0200, Andi Kleen wrote:
> On 9/22/2010 10:30 PM, Nicholas A. Bellinger wrote:
> > From: Nicholas Bellinger<nab@linux-iscsi.org>
> >
> > This patch updates siw_create_qp() to check for the CONFIG_X86 + cpu_has_xmm4_2
> > dependent use of the CRC32C instruction offload using libcrypto crc32c-intel.ko.
> > This patch will by default use crc32c-intel when available, and fall back to the
> > legacy slicing by 1x libcrypto crc32c.ko code when the instruction offload is not
> > availabe.
> 
> I don't think every caller should handle checks like this. The crypto 
> layer should load the right driver
> instead and provide the best driver under a generic algorithm name.
> 

Indeed, this would clean up the explict RX/TX CRC32C case quite a bit..
Unfortuately I am too busy with other items atm to cook up this patch,
but I would be happy to test it if someone wants to take it.  ;)

> Need CPUID module auto probing. I have an older patch that needs some fixes.
> 

Hmm, I don't see how that fits in here exactly.  Would you mind
elaborating a bit..?

Thanks!

--nab
