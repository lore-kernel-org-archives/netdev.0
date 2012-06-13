From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next patch 8/12] bnx2x: Allow up to 63 RSS queues default
 8 queues
Date: Wed, 13 Jun 2012 11:52:55 +0200
Message-ID: <1339581175.22704.342.camel@edumazet-glaptop>
References: <1339591464-10554-1-git-send-email-meravs@broadcom.com>
	 <1339591464-10554-9-git-send-email-meravs@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, davem@davemloft.net, netdev@vger.kernel.org
To: Merav Sicron <meravs@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:58805 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab2FMJxC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2012 05:53:02 -0400
Received: by eeit10 with SMTP id t10so117716eei.19
        for <netdev@vger.kernel.org>; Wed, 13 Jun 2012 02:53:01 -0700 (PDT)
In-Reply-To: <1339591464-10554-9-git-send-email-meravs@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-06-13 at 15:44 +0300, Merav Sicron wrote:
> This patch removed the limitation in the code for 16 RSS queues. The default
> (without other instruction from the user) number of queues is determined
> according to the number of MSI-X vectors supported for that function, the number
> of CPUs in the system, and a maximum of 8 queues.

Thats a very confusing changelog

You meant : " a minimum of 8 queues" ?

You should give more explanations, because its a sensible area for
performances.
