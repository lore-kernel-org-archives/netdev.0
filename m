From: Jamie Lokier <jamie@shareable.org>
Subject: Re: [PATCH]: altq HFSC port
Date: Mon, 26 Jan 2004 23:59:57 +0000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040126235957.GA30186@mail.shareable.org>
References: <Pine.GSO.4.42.0401261228290.22399-200000@stinky.trash.net> <1075128375.1746.392.camel@jzny.localdomain> <40155F1A.7070507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: hadi@cyberus.ca, netdev@oss.sgi.com, linux-net@vger.kernel.org,
        "David S. Miller" <davem@redhat.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <40155F1A.7070507@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> I talked to the original authors and they removed the advertising
> clause
> (http://orange.kame.net/dev/cvsweb.cgi/kame/kame/sys/altq/altq_hfsc.c),
> but they didn't want to release the code under the GPL. Various posts on
> linux-kernel indicate that combining GPL code with BSD code without
> advertising clause makes the end-product automatically be subject to the
> GPL, even without consent of the authors. I basically meant to ask if
> this is true.

Yes, the end-product Linux kernel (the combined work) is subject to
the GPL.  You _do_ have the consent of the authors: their decision to
release under the BSD-without-advertising license _is_ consent to
incorporate it into a GPL work, just as it is consent to incorporate
it into a closed source work.  Asking for their blessing is politeness.

When the authors release the code under the BSD-without-advertising
clause, they are declaring that it's ok to use the code in lots of
different ways.  One of those is that it's ok to re-release the code
under GPL - the authors may not like that, but they have explicitly
declared that you may to do it.

You can do that.
Alternatively you can keep the code licensed under BSD-without-advertising.

When you combine BSD-without-advertising code with GPL code, the
resulting combined work is covered by both licenses, and because the
BSD-without-advertising permissions are a superset of the GPL
permissions, the combined work is effectively covered by the GPL.

However, the BSD-without-advertising code retains its own license, and
provided it remains an "identifiable section" of the program and "can
be reasonably considered independent and separate" in itself, then
anyone may copy that code from the combined work and use it according
to the BSD-without-advertising license.  See clause 2, paragraph 5 of
the GPL.  Unfortunately it is not 100% clear on this matter.

Whether that code remains independent and separate will depend on the
changes made and the licensing of patches, which is a grey area
because people don't tend to make the licensing of Linux patches
clear.  Most likely, as soon as people make changes to the code within
the context of Linux development, it may be assumed that the derived
work (the hfsc code + patches from Linux authors) is covered by the GPL.

Btw, IANAL.
-- Jamie
