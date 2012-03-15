From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Patch to ip(8) manpage
Date: Thu, 15 Mar 2012 14:34:35 -0700
Message-ID: <20120315143435.7f3b8482@nehalam.linuxnetplumber.net>
References: <alpine.DEB.2.00.1203031007180.22132@bakacsin.ki.iif.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Kiss Gabor (Bitman)" <kissg@ssg.ki.iif.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:47173 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030370Ab2COVei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Mar 2012 17:34:38 -0400
In-Reply-To: <alpine.DEB.2.00.1203031007180.22132@bakacsin.ki.iif.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 3 Mar 2012 10:18:01 +0100 (CET)
"Kiss Gabor (Bitman)" <kissg@ssg.ki.iif.hu> wrote:

> Dear folks,
> 
> For a while I did not understand why I get
> "RTNETLINK answers: Numerical result out of range"
> message when adding more addresses to an interface.
> 
> The attached patch may help some peoples to avoid wasting
> time with investigating this strange error. :-)
> 
> Regards
> 
> Gabor

There are many  values limited to 16 characters, this is an API
restriction back to BSD days (see IFNAMSIZ).  The man page could mention
this, but it is well known limitation. The manpage idea is good,
but don't reference net/if.h since somebody might get the idea that is
the only thing that needs to change to allow longer names. Just state
that interface names are limited to 15 characters (need to account for
the nul at end).
