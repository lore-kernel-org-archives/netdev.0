From: "Peter W. Morreale" <pmorreale@novell.com>
Subject: Re: High contention on the sk_buff_head.lock
Date: Thu, 19 Mar 2009 07:36:01 -0600
Message-ID: <1237469761.6926.47.camel@hermosa>
References: <49C12E64.1000301@us.ibm.com> <87prge1rhu.fsf@basil.nowhere.org>
	 <1237467559.6926.31.camel@hermosa>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Vernon Mauery <vernux@us.ibm.com>, netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	rt-users <linux-rt-users@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charybdis-ext.suse.de ([195.135.221.2]:45998 "EHLO
	emea5-mh.id5.novell.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751671AbZCSNgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 09:36:11 -0400
In-Reply-To: <1237467559.6926.31.camel@hermosa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-03-19 at 06:59 -0600, Peter W. Morreale wrote:
> On Wed, 2009-03-18 at 21:54 +0100, Andi Kleen wrote:
> > Vernon Mauery <vernux@us.ibm.com> writes:
> > >
> 
> > 
> > But then again I'm not sure it's  worth it if the problem only
> > happens in out of tree RT.
> > 
> 
> Heh.  That darn bastard child again, eh?  :-)
> 
> 
> Recall that adaptive spin,developed in RT, is now in mainline. 
> 

Err..  correction... *about* to be in mainline.   Only point I'm making
is that RT does implicitly, if not explicitly, contributes to mainline.
Its not a one-way street. 

Best,
-PWM

> Best,
> -PWM
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rt-users" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

