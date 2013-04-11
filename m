From: Bart Van Assche <bvanassche@acm.org>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from spin_lock_mutex
Date: Thu, 11 Apr 2013 19:31:07 +0200
Message-ID: <5166F35B.1040200@acm.org>
References: <5166BDAA.3000603@acm.org> <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from jacques.telenet-ops.be ([195.130.132.50]:46285 "EHLO
	jacques.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935328Ab3DKRbK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 13:31:10 -0400
In-Reply-To: <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/13 17:18, Neil Horman wrote:
> Bart, this patch should fix your problem.  Could you please test it a=
nd confirm?

The fails to build on my setup after having applied that patch:

kernel/mutex.c: In function =91__mutex_trylock_slowpath=92:
kernel/mutex.c:446:2: error: implicit declaration of function=20
=91spin_unlock_mutex_raw=92 [-Werror=3Dimplicit-function-declaration]

Bart.
