From: David Vrabel <dvrabel@cantab.net>
Subject: Re: [PATCH 2/2] ipg: redundancy with mii.h
Date: Thu, 04 May 2006 07:52:22 +0100
Message-ID: <4459A4A6.1080207@cantab.net>
References: <1146342905.11271.3.camel@localhost> <1146389171.11524.1.camel@localhost> <44554ADE.8030200@cantab.net> <4455F1D8.5030102@cantab.net> <1146506939.23931.2.camel@localhost> <20060501231206.GD7419@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605020945010.4066@sbz-30.cs.Helsinki.FI> <20060502214520.GC26357@electric-eye.fr.zoreil.com> <20060502215559.GA1119@electric-eye.fr.zoreil.com> <Pine.LNX.4.58.0605030913210.6032@sbz-30.cs.Helsinki.FI> <20060503233558.GA27232@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Pekka J Enberg <penberg@cs.Helsinki.FI>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	david@pleyades.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from rutherford.zen.co.uk ([212.23.3.142]:21384 "EHLO
	rutherford.zen.co.uk") by vger.kernel.org with ESMTP
	id S1751377AbWEDGwX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 02:52:23 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060503233558.GA27232@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> 
>     ipg: remove forward declarations
>     
>     It makes no sense in a new driver.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Ack.

>     ipg: replace #define with enum
>     
>     Added some underscores to improve readability.
>     
>     Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

Nack.  Register names in code should match those used in the 
documentation (even if they are a bit unreadable).  Though I will 
conceed that the available datasheet doesn't actually describe the 
majority of the registers.

>     ipg: removal of useless #defines
>     
>     IPG_TX_NOTBUSY apart (one occurence in ipg.c), the #defines appear
>     nowhere in the sources.

Ack.

>     ipg: redundancy with mii.h - take II
>     
>     Replace a bunch of #define with their counterpart from mii.h
>     
>     It is applied to the usual MII registers this time.

Ack.

