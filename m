From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: qla3xxx: sleep in atomic
Date: Wed, 13 Jan 2010 13:31:42 +0100
Message-ID: <4B4DBD2E.6040407@gmail.com>
References: <4B4DBB4D.9070807@gmail.com> <4B4DBC1E.9070505@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Cc: linux-driver@qlogic.com, netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:60082 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751384Ab0AMMbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 07:31:45 -0500
Received: by fxm25 with SMTP id 25so94408fxm.21
        for <netdev@vger.kernel.org>; Wed, 13 Jan 2010 04:31:44 -0800 (PST)
In-Reply-To: <4B4DBC1E.9070505@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2010 01:27 PM, Jiri Slaby wrote:
> On 01/13/2010 01:23 PM, Jiri Slaby wrote:
>> stanse found a potential sleep inside atomic context. ql_sem_spinlock
>> must be called with hw_lock which is spinlock (locked with irq disabled
> 
> I've sent it too early. I overlooked another report before. The same
> holds for ql_wait_for_drvr_lock.

Fuck, and for ql_adapter_reset from both qla3xxx and qlge plus
ql_sem_trylock from the latter.

-- 
js
