From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: SEEPROM test patch
Date: Tue, 14 Apr 2009 17:44:17 +0000
Message-ID: <1239731057.3357.71.camel@mulgrave.int.hansenpartnership.com>
References: <20090414172123.GA12319@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Robin Holt <holt@sgi.com>, Michael Chan <mchan@broadcom.com>,
	netdev@vger.kernel.org, Parisc List <linux-parisc@vger.kernel.org>
To: Matt Carlson <mcarlson@broadcom.com>
Return-path: <linux-parisc-owner@vger.kernel.org>
In-Reply-To: <20090414172123.GA12319@xw6200.broadcom.net>
Sender: linux-parisc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2009-04-14 at 10:21 -0700, Matt Carlson wrote:
> James, Robin.  I looked through the patches again and found that the
> SEEPROM routines were not being adjusted correctly along with the flash
> NVRAM access routines.  The patch below should shore up the difference.
> The patch works on both BE and LE systems.
> 
> Can you apply the patch below and see if it fixes your problem?  (You
> may have to back out David's changes for the mac addresses to be
> restored, but 'eeprom -e' dumps should be fixed.)  If it does, I'll
> post a replacement patch that documents why the code is doing what it's
> doing.

Yes, that seems to work better:  both the mac address and ethtool -e
output are back to what 2.6.29 reports.

James


