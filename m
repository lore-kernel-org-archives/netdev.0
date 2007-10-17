From: Milan Kocian <milon@wq.cz>
Subject: Re: Difference between device statistics from ifconfig and ip -s l
	l
Date: Wed, 17 Oct 2007 15:42:49 +0200
Message-ID: <20071017134249.GD16356@wq.cz>
References: <20071017092659.GA16356@wq.cz> <4715D79E.7020201@trash.net> <20071017101303.GB16356@wq.cz> <4715E57F.6080905@trash.net> <20071017112919.GC16356@wq.cz> <1192622498.4460.25.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-sitel.lam.cz ([212.71.129.172]:49251 "EHLO nt.wq.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754295AbXJQNnG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 09:43:06 -0400
Content-Disposition: inline
In-Reply-To: <1192622498.4460.25.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 17, 2007 at 08:01:38AM -0400, jamal wrote:
> > 
> > One probably stupid question: Why is not done similar sum in output of 'ip -s l l' ?
> 
> "missed" is not really an error. It just means the driver was
> overwhelmed and didnt even get the chance of seeing it whereas an error
> is something the driver processed and saw a problem with it.
> 
Thanks for explanation. But if I understand well, the packet is lost anyway, isn't it ?
And when the packet is lost and I want to see all problems, I have to use detailed 
(ip -s -s ) stats because non-detailed (ip -s ) stats may hide problems. True ?

If yes then using non-detailed stats lacks sense.

> > Imagine me :), I do 'ifconfig' and see dropped packets and then I do 'ip -s l l'
> > and see zeros. I stare on it like an idiot. Where is bug ? ifconfig ? ip ?
> > (man page of ip and 'ip -s -s l l' with missed packets stats saved me :).
> > 
> > IMHO I think that comparable outputs of both programs should be still the same.
> 
> I think ifconfig sums them up so the output formatting looks nice, but
> ip is more accurate. These stats are from standard SNMP mibs (off top of
> my head RFC1213 if it hasnt been obsoleted by something) - look at
> InIFxxxx stats.
> 
I will try to look at. Thanks!

> cheers,
> jamal
> 
regards,

-- 
Milan Kocian
