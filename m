From: Keith Owens <kaos@ocs.com.au>
Subject: Re: [git patch] urgent e1000 fix
Date: Fri, 24 Jun 2005 18:22:59 +1000
Message-ID: <13661.1119601379@kao2.melbourne.sgi.com>
References: <200506240949.05620.vda@ilport.com.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>,
	David Lang <david.lang@digitalinsight.com>,
	Andrew Morton <akpm@osdl.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S263227AbVFXIZr@vger.kernel.org>
To: Denis Vlasenko <vda@ilport.com.ua>
In-reply-to: Your message of "Fri, 24 Jun 2005 09:49:05 +0300."
             <200506240949.05620.vda@ilport.com.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Jun 2005 09:49:05 +0300, 
Denis Vlasenko <vda@ilport.com.ua> wrote:
>On Friday 24 June 2005 02:33, Linus Torvalds wrote:
>> To actually allow real fuzz or to allow real whitespace differences in the
>> patch data itself is a _much_ bigger issue than this trivial patch
>> corruption, and I'd prefer to avoid going there if at all possible.
>
>How about automatic stripping of _trailing_ whitespace on all incoming
>patches? IIRC no file type (C, sh, Makefile, you name it) depends on
>conservation of it, thus it's 100% safe.

One (admittedly rare) case - adding a text file that contains an
embedded patch, so you have a patch that includes a patch.  This is
sometimes done in Documentation files when an external file has to be
changed.  In embedded patch, empty lines are converted to a single
space, which then appears as trailing whitespace.  Not sure if that is
a big enough reason not to strip whitespace.
