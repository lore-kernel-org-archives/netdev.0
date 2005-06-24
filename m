From: Denis Vlasenko <vda@ilport.com.ua>
Subject: Re: [git patch] urgent e1000 fix
Date: Fri, 24 Jun 2005 09:49:05 +0300
Message-ID: <200506240949.05620.vda@ilport.com.ua>
References: <42BA7FB5.5020804@pobox.com> <42BB4172.5000904@pobox.com> <Pine.LNX.4.58.0506231625310.11175@ppc970.osdl.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Lang <david.lang@digitalinsight.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S262623AbVFXGtW@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>, Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <Pine.LNX.4.58.0506231625310.11175@ppc970.osdl.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 24 June 2005 02:33, Linus Torvalds wrote:
> To actually allow real fuzz or to allow real whitespace differences in the
> patch data itself is a _much_ bigger issue than this trivial patch
> corruption, and I'd prefer to avoid going there if at all possible.

How about automatic stripping of _trailing_ whitespace on all incoming
patches? IIRC no file type (C, sh, Makefile, you name it) depends on
conservation of it, thus it's 100% safe.
--
vda
