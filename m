From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC PATCH 1/5] libfcoe, fcoe: Allow user to set a ctlr's mode
Date: Mon, 10 Sep 2012 16:12:11 -0700
Message-ID: <20120910231211.GB14302@kroah.com>
References: <20120910225908.13140.97277.stgit@fritz>
 <20120910225914.13140.22190.stgit@fritz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	bprakash@broadcom.com, devel@open-fcoe.org
To: Robert Love <robert.w.love@intel.com>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120910225914.13140.22190.stgit@fritz>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2012 at 03:59:14PM -0700, Robert Love wrote:
> This patch makes the 'mode' attribute of a
> fcoe_ctlr_device writale. This allows the user
> to store the mode with with the ctlr will be in.
> 
> Possible modes would be 'Fabric', or 'VN2VN'.
> 
> The default mode for a fcoe_ctlr{,_device} is 'Fabric'.
> Drivers must implement the set_fcoe_ctlr_mode routine
> to support this feature.
> 
> libfcoe offers an exported routine to set a fcoe_ctlr's
> mode.
> 
> Signed-off-by: Robert Love <robert.w.love@intel.com>

Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

