From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: where is the proper place for r8169 bug reports?
Date: Mon, 31 Jan 2005 23:23:42 +0100
Message-ID: <20050131222342.GB13217@electric-eye.fr.zoreil.com>
References: <20050131181508.GA15908@gerbil.toadis.porkis> <20050131214951.GA13217@electric-eye.fr.zoreil.com> <20050131215948.GA23289@gerbil.toadis.porkis>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "Dale E. Martin" <dale@the-martins.org>
Content-Disposition: inline
In-Reply-To: <20050131215948.GA23289@gerbil.toadis.porkis>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dale E. Martin <dale@the-martins.org> :
[...]
> Hmmm, OK.  I'm running Debian stable so that is what cc defaults to.  I'll
> recompile with 3.3 and see if the problems go away.  It could easily
> explain the difference between machines too.

Typical symptoms: the card works fine until 64 (256) packets are sent
(received) then "Good bye Charlie".

If it works, I'll gladly welcome an 'lspci -vx' + complete dmesg for my
collection.

Btw, you can test the patch below (on top of 2.4.28, no bad report so far):
http://www.fr.zoreil.com/~romieu/misc/20041209-2.4.28-r8169.c-test.patch

--
Ueimor
