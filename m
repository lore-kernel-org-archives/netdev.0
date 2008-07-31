From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [PATCH] PCI: Add limits to VPD read/write lengths for Broadcom 5706S, 5708S
Date: Thu, 31 Jul 2008 12:41:05 -0700
Message-ID: <200807311241.06209.jbarnes@virtuousgeek.org>
References: <48920413.6080508@cosmosbay.com> <1217532284-7032-1-git-send-email-benli@broadcom.com> <1217532284-7032-2-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Matthew Wilcox" <willy@linux.intel.com>,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Linux Netdev List" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Benjamin Li" <benli@broadcom.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1217532284-7032-2-git-send-email-benli@broadcom.com>
Content-Disposition: inline
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, July 31, 2008 12:24 pm Benjamin Li wrote:
> Reading beyond the valid VPD limit will hang the Broadcom
> 5706S, 5708S.  During the check we need to add the additionial
> 5706S and 5708S PCI ID's when limiting the read/write VPD length.
>
> Signed-off-by: Benjamin Li <benli@broadcom.com>

I already applied Eric's 5708S patch, can you re-diff against my for-linus 
branch (in a few minutes after it mirrors out) and resend?  And please cc 
stable@vger.kernel.org, since they'll want these crash fixes too.

Thanks,
Jesse
