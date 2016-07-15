From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 2/8] thunderbolt: Updating device IDs
Date: Fri, 15 Jul 2016 11:49:02 -0700 (PDT)
Message-ID: <20160715.114902.1149848183971707484.davem@davemloft.net>
References: <1468495702-7467-1-git-send-email-amir.jer.levy@intel.com>
	<1468495702-7467-3-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andreas.noever@gmail.com, gregkh@linuxfoundation.org,
	bhelgaas@google.com, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	thunderbolt-linux@intel.com, mika.westerberg@intel.com,
	tomas.winkler@intel.com
To: amir.jer.levy@intel.com
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <1468495702-7467-3-git-send-email-amir.jer.levy@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Amir Levy <amir.jer.levy@intel.com>
Date: Thu, 14 Jul 2016 14:28:16 +0300

> Adding the new Thunderbolt(TM) device IDs to the list.
> 
> Signed-off-by: Amir Levy <amir.jer.levy@intel.com>

Unless these PCI-IDs, all of them, are going to be used in multiple
spots in the kernel, it is not appropriate to add them here.

They belong as private macros in the drivers themselves, instead.
