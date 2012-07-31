From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [RFC v2 1/2] PCI-Express Non-Transparent Bridge Support
Date: Tue, 31 Jul 2012 16:14:31 -0700
Message-ID: <20120731231431.GA1558@kroah.com>
References: <1343607994-32415-1-git-send-email-jon.mason@intel.com>
 <1343607994-32415-2-git-send-email-jon.mason@intel.com>
 <20120731222338.GA19134@kroah.com>
 <20120731225105.GD14080@jonmason-lab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-pci@vger.kernel.org, Dave Jiang <dave.jiang@intel.com>
To: Jon Mason <jon.mason@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:39832 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754989Ab2GaXOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jul 2012 19:14:36 -0400
Received: by obbuo13 with SMTP id uo13so11291710obb.19
        for <netdev@vger.kernel.org>; Tue, 31 Jul 2012 16:14:35 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120731225105.GD14080@jonmason-lab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 31, 2012 at 03:51:05PM -0700, Jon Mason wrote:
> On Tue, Jul 31, 2012 at 03:23:38PM -0700, Greg KH wrote:
> > On Sun, Jul 29, 2012 at 05:26:33PM -0700, Jon Mason wrote:
> > > + *   You should have received a copy of the GNU General Public License
> > > + *   along with this program; if not, write to the Free Software
> > > + *   Foundation, Inc., 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
> > 
> > You really are going to track the FSF's office movements for the next
> > 40+ years?
> > 
> > > + *   The full GNU General Public License is included in this distribution
> > > + *   in the file called LICENSE.GPL.
> > 
> > No it isn't, this sentance is totally wrong for any in-kernel code,
> > please remove it.
> > 
> > Also do the same for all the other files you added please.
> 
> I echo'ed your original comments on this to Intel Legal and am waiting
> on a response.  I 100% agree, but I need their signoff first.
> 
> It is worth noting that this version of the license is already in the
> kernel in numerous other drivers:
> drivers/sfi/*
> drivers/scsi/isci/*
> drivers/dma/ioat/dma_v3.c
> drivers/net/wireless/iwlwifi/*
> drivers/net/wireless/iwlegacy/*

Just because others got it wrong, doesn't mean you need to continue to :)

greg k-h
