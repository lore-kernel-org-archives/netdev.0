From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: qla3xxx: sleep in atomic
Date: Wed, 13 Jan 2010 13:27:10 +0100
Message-ID: <4B4DBC1E.9070505@gmail.com>
References: <4B4DBB4D.9070807@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:35736 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751312Ab0AMM1M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 07:27:12 -0500
Received: by fg-out-1718.google.com with SMTP id 22so177124fge.1
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2010 04:27:11 -0800 (PST)
In-Reply-To: <4B4DBB4D.9070807@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2010 01:23 PM, Jiri Slaby wrote:
> stanse found a potential sleep inside atomic context. ql_sem_spinlock
> must be called with hw_lock which is spinlock (locked with irq disabled

I've sent it too early. I overlooked another report before. The same
holds for ql_wait_for_drvr_lock.

-- 
js
