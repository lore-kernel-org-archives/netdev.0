From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [PATCH] acxsm: Reduce the number of ACX_PACKED instructions
Date: Thu, 13 Apr 2006 15:33:57 +0300
Message-ID: <200604131533.57478.vda@ilport.com.ua>
References: <11433168763687-git-send-email-carlos@cmartin.tk> <20060412205756.GD12788@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Carlos Martin <carlos@cmartin.tk>, netdev@vger.kernel.org,
	acx100-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 167.imtp.Ilyichevsk.Odessa.UA ([195.66.192.167]:31896 "HELO
	ilport.com.ua") by vger.kernel.org with SMTP id S964904AbWDMMef
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Apr 2006 08:34:35 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060412205756.GD12788@tuxdriver.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 12 April 2006 23:58, John W. Linville wrote:
> On Sat, Mar 25, 2006 at 09:01:16PM +0100, Carlos Martin wrote:
> > Up to now, we were using ACX_PACKED after every field. I've finally
> > found out how to use only one at the end of each struct whilst
> > maintaining the typedef where it is now.
> > 
> > This should also apply to acx with a bit of fuzz, but I consider it to
> > be in maintenance mode, so this doesn't qualify for it.
> > 
> > Signed-off-by: Carlos Martin <carlos@cmartin.tk>
> > 
> > ---
> > 
> >  acx_struct.h |  874 +++++++++++++++++++++++++++++-----------------------------
> >  common.c     |   26 +-
> >  ioctl.c      |   10 -
> >  usb.c        |    8 -
> >  4 files changed, 457 insertions(+), 461 deletions(-)
> > 
> > 5fb2fdfd8c028a40921bbf9ef7ec4c53c03fcab4
> > diff --git a/acx_struct.h b/acx_struct.h
> 
> Denis, have you got this patch?  Or do I need to apply it?

I tried to sync with your git tree, but:

Sometime ago I downloaded softmac git tree with

# cg-branch-add r-softmac 'rsync://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git#softmac'

but today I can't update from that:

# cg-update r-softmac
Recovering from a previously interrupted fetch...
WARNING: The rsync access method is DEPRECATED and will be REMOVED in the future!
Fetching head...
MOTD:
MOTD:   Welcome to the Linux Kernel Archive.
MOTD:
MOTD:   Due to U.S. Exports Regulations, all cryptographic software on this
MOTD:   site is subject to the following legal notice:
MOTD:
MOTD:   This site includes publicly available encryption source code
MOTD:   which, together with object code resulting from the compiling of
MOTD:   publicly available source code, may be exported from the United
MOTD:   States under License Exception "TSU" pursuant to 15 C.F.R. Section
MOTD:   740.13(e).
MOTD:
MOTD:   This legal notice applies to cryptographic software only.
MOTD:   Please see the Bureau of Industry and Security,
MOTD:   http://www.bis.doc.gov/ for more information about current
MOTD:   U.S. regulations.
MOTD:

receiving file list ... done

sent 4 bytes  received 9 bytes  0.36 bytes/sec
total size is 0  speedup is 0.00
cg-fetch: unable to get the head pointer of branch softmac

Did you rename softmac branch again?
--
vda
