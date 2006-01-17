From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH ] ethtool: Remove duplex info from CTRL register dump
Date: Tue, 17 Jan 2006 08:08:47 -0500
Message-ID: <43CCEC5F.7020801@pobox.com>
References: <20060112071642.29428.23880.stgit@Gecko.tarbal.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932467AbWAQNIw@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
In-Reply-To: <20060112071642.29428.23880.stgit@Gecko.tarbal.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Kirsher wrote:
> The duplex control register is used for setting the driver and is not
> necessary for debug purposes.  The value of the duplex control register is
> what the register's current value is and may not reflect the correct status
> of te current connection.  That is what the duplex status register is used
> for.  To keep from confusing the user, we are removing the duplex register
> from the ethtool dump of the registers.
> 
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Signed-off-by: John Ronciak <john.ronciak@intel.com>

applied, after replacing "ethtool:" with "e1000:" in the subject line.

	Jeff
