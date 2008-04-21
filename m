From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] Re: Bad network performance over 2Gbps
Date: Mon, 21 Apr 2008 20:35:55 +0200
Message-ID: <87hcdv6ook.fsf@basil.nowhere.org>
References: <1208282804.23631.27.camel@localhost>
	<175f5a0f0804151315x1e192fc7p7dac1e84fd154211@mail.gmail.com>
	<48051173.5030802@intel.com> <48051734.1000107@redhat.com>
	<1208426550.6049.10.camel@localhost> <48078AF6.2020003@intel.com>
	<20080421152821.GA18452@elte.hu> <480CC7A7.4070709@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Anton Titov <a.titov@host.bg>, Chris Snook <csnook@redhat.com>,
	"H. Willstrand" <h.willstrand@gmail.com>, netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out04.alice-dsl.net ([88.44.63.6]:2145 "EHLO
	smtp-out04.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752174AbYDUSgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 14:36:12 -0400
In-Reply-To: <480CC7A7.4070709@intel.com> (Auke Kok's message of "Mon, 21 Apr 2008 09:58:15 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Kok, Auke" <auke-jan.h.kok@intel.com> writes:

> Ingo Molnar wrote:
>> * Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>> 
>>> We keep seing this exact issue pop up everywhere - especially with 
>>> e1000(e) datacenter users - this code _has_ to go or be fixed. Since 
>>> there is a perfectly viable solution, I strongly suggest disabling it.
>> 
>> strongly agreed. Thanks Auke, applied.
>> 
>> 	Ingo
>
>
> excellent, ignore my other reply to Pavel - I didn't see this reply yet :)

Shouldn't you just add it to the FeatureRemoval list too and remove it 
then quickly? No need to keep disabled and known to be wrong code around.

-Andi
