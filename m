From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: Tc bug (kernel crash) more info
Date: Wed, 29 Aug 2007 13:34:47 +0200
Message-ID: <20070829113447.GA3575@ff.dom.local>
References: <46D53D9C.5070204@bigtelecom.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Badalian Vyacheslav <slavon@bigtelecom.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:40727 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755269AbXH2Ld3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Aug 2007 07:33:29 -0400
Content-Disposition: inline
In-Reply-To: <46D53D9C.5070204@bigtelecom.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 29-08-2007 11:34, Badalian Vyacheslav wrote:
> Again crash.  Need more posts of panic or this message have full info 
> that needed to fix bug?

Hi,

Please, try to not create new threads each time: reply to the previous
one if you have something new. And this one doesn't seem to show more.
You have written earlier it's '1-5 times on week', so you should have
got used to it a little, so no need to panic...

You would better try to write if there was some previous kernel
version, which worked better for you?

It seems, there could be some locking problem and your script could
mess htb queue from the second cpu (or is interrupted). Probably you
could have something more in logs about this, and maybe even this
script could be helpful (you should mask secret things only). Or maybe
you could try to add some echos to this script to figure out the
part which is the most suspected. Of course .config and dmesg (zipped)
could be helpful too.

If it's possible you can try it shortly without e.g. netconsole or
even without CONFIG_SMP.

Regards,
Jarek P.
