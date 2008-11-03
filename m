From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] PCI: Limit VPD length for Broadcom 5708S
Date: Mon, 3 Nov 2008 14:37:57 -0800
Message-ID: <200811031437.57997.jbarnes@virtuousgeek.org>
References: <48920413.6080508@cosmosbay.com> <4906AF5F.9040704@cosmosbay.com> <20081028064411.GA7043@yzhao12-linux.sh.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>, benli@broadcom.com,
	"willy@linux.intel.com" <willy@linux.intel.com>,
	linux kernel <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Michael Chan <mchan@broadcom.com>
To: Yu Zhao <yu.zhao@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756607AbYKCWiW@vger.kernel.org>
In-Reply-To: <20081028064411.GA7043@yzhao12-linux.sh.intel.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday, October 27, 2008 11:44 pm Yu Zhao wrote:
> VPD quirks needs to be called after the capability is initialized. Since
> VPD initialization is move to after pci_fixup_header, VPD quirks should
> be done at pci_fixup_final stage correspondingly.
>
> Signed-off-by: Yu Zhao <yu.zhao@intel.com>

Thanks Yu.  Applied to my for-linus branch.  Looks like that was the only 
affected quirk.

Jesse
