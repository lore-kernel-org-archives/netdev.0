From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: Patch: link state detection for 8139too against 2.4.20rc2 / 2.5
Date: Mon, 9 Dec 2002 18:25:59 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021209232559.GA9473@gtf.org>
References: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com> <3DA96BCC.B2589AC0@isg.de> <3DE0CA4C.730699FC@isg.de> <3DF51ADB.47E83F81@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stefan Rompf <srompf@isg.de>
Content-Disposition: inline
In-Reply-To: <3DF51ADB.47E83F81@isg.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Dec 09, 2002 at 11:36:11PM +0100, Stefan Rompf wrote:
> Hi,
> 
> Jeff Garzik wrote:
> 
> > > ...that was some days ago. I've seen that Jeff is enhancing the MII
> > > interface library, so I used the functions provided there. Patch is
> > > against 2.4.20rc2 and 2.5 with some offset. Please apply if it looks
> > > good.
> 
> [...]
> 
> > close -- you don't want to unconditionally "initialize" the media 
> > (mii_check_media second arg).
> 
> I've just seen the reason: No need to read the MII_ADVERTISE register
> once the structure has been initialized. Expect another patch the next
> days.

Thanks.


> > the phy code is gonna be pretty darned similar.  Eventually the phy code 
> > needs to move to a common 8139lib.c, because both old-8139 line and 
> 
> May be. However, I cannot help there. I just have one card of the 8139
> family, and all I could produce is some compiles for me stuff -
> something that I would not consider helpful.

<shrug>  I would consider it helpful.  If you are willing to do the
coding and worksforme testing, I can review and do further testing.
Part of the power of open source :)

	Jeff
