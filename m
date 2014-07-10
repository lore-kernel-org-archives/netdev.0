From: David Miller <davem@davemloft.net>
Subject: Re: [net] igb: do a reset on SR-IOV re-init if device is down
Date: Thu, 10 Jul 2014 12:45:54 -0700 (PDT)
Message-ID: <20140710.124554.198992535732818114.davem@davemloft.net>
References: <1404988179-2640-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sassmann@kpanic.de, netdev@vger.kernel.org, nhorman@redhat.com,
	sassmann@redhat.com, stable@vger.kernel.org
To: jeffrey.t.kirsher@intel.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1404988179-2640-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Thu, 10 Jul 2014 03:29:39 -0700

> From: Stefan Assmann <sassmann@kpanic.de>
> 
> To properly re-initialize SR-IOV it is necessary to reset the device
> even if it is already down. Not doing this may result in Tx unit hangs.
> 
> Cc: stable <stable@vger.kernel.org>
> Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
> Tested-by: Aaron Brown <aaron.f.brown@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks Jeff.
