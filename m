From: Dan Carpenter <error27@gmail.com>
Subject: Re: [PATCH] tg3: fix return value check in tg3_read_vpd()
Date: Mon, 27 Dec 2010 23:19:27 +0300
Message-ID: <20101227201927.GA6365@bicker>
References: <1293471094-28976-1-git-send-email-dsterba@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mcarlson@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Michael Chan <mchan@broadcom.com>
To: David Sterba <dsterba@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1293471094-28976-1-git-send-email-dsterba@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 27, 2010 at 06:31:34PM +0100, David Sterba wrote:
> CC: Matt Carlson <mcarlson@broadcom.com>
> CC: Michael Chan <mchan@broadcom.com>
> Signed-off-by: David Sterba <dsterba@suse.cz>
> ---

Your fix is obviously correct, but could you describe the symptoms
in your changelog instead of leaving it blank?  In the original code,
negative error values are ignored so we never goto out_not_found.  Can
pci_read_vpd() return any errors we care about besides -ENODEV?  What I
mean is, did you find this through analysing the code or did it cause a
bug at runtime?

regards,
dan carpenter
