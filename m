From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 9/15] BE NIC driver - Linux system abstraction files
Date: Thu, 15 May 2008 13:33:05 +0200
Message-ID: <87mymrztse.fsf@basil.nowhere.org>
References: <20080515092638.a9ce4c89@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Subbu Seetharaman" <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.alice-dsl.net ([88.44.63.5]:54672 "EHLO
	smtp-out03.alice-dsl.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754265AbYEOLeI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 07:34:08 -0400
In-Reply-To: <20080515092638.a9ce4c89@mailhost.serverengines.com> (Subbu Seetharaman's message of "Thu, 15 May 2008 02:26:38 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Subbu Seetharaman" <subbus@serverengines.com> writes:
> + */
> +/*
> + * system abstraction functions / macros for Linux

Sorry, pretty much this complete file has to go and the callers 
be fixed to use the native Linux functions directly. Some of it
was even wrong, like it's not legal to cast atomic_t like you did.

Also a lot of facilities you reimplement here exist already in Linux
anyways under other names.

> This message, together with any attachment(s), contains confidential and proprietary information of
> ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
> review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the

Hmm was i even allowed to read it?

-Andi
