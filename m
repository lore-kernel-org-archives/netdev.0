From: Stefan Rompf <srompf@isg.de>
Subject: Re: Patch: link state detection for 8139too against 2.4.20rc2 / 2.5
Date: Mon, 09 Dec 2002 23:36:11 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DF51ADB.47E83F81@isg.de>
References: <Pine.LNX.4.44.0210120013500.1159-100000@beohost.scyld.com> <3DA96BCC.B2589AC0@isg.de> <3DE0CA4C.730699FC@isg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

Jeff Garzik wrote:

> > ...that was some days ago. I've seen that Jeff is enhancing the MII
> > interface library, so I used the functions provided there. Patch is
> > against 2.4.20rc2 and 2.5 with some offset. Please apply if it looks
> > good.

[...]

> close -- you don't want to unconditionally "initialize" the media 
> (mii_check_media second arg).

I've just seen the reason: No need to read the MII_ADVERTISE register
once the structure has been initialized. Expect another patch the next
days.

> the phy code is gonna be pretty darned similar.  Eventually the phy code 
> needs to move to a common 8139lib.c, because both old-8139 line and 

May be. However, I cannot help there. I just have one card of the 8139
family, and all I could produce is some compiles for me stuff -
something that I would not consider helpful.

Stefan
