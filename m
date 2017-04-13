From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next 4/8] net/ncsi: Add debugging infrastructurre
Date: Wed, 12 Apr 2017 21:28:26 -0700
Message-ID: <1492057706.28586.10.camel@perches.com>
References: <1492051600-26706-1-git-send-email-gwshan@linux.vnet.ibm.com>
         <1492051600-26706-5-git-send-email-gwshan@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: Gavin Shan <gwshan@linux.vnet.ibm.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0027.hostedemail.com ([216.40.44.27]:48344 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751573AbdDME2h (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Apr 2017 00:28:37 -0400
In-Reply-To: <1492051600-26706-5-git-send-email-gwshan@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-04-13 at 12:46 +1000, Gavin Shan wrote:
> This creates procfs directories as NCSI debugging infrastructure.
> With the patch applied, We will see below procfs directories. Every
> NCSI package and channel has one corresponding directory. Other than
> presenting the NCSI topology, No real function has been achieved
> through these procfs directories so far.

/proc is meant to be stable.

Why not use debugfs?

>      /proc/ncsi/eth0
>      /proc/ncsi/eth0/p0
>      /proc/ncsi/eth0/p0/c0
>      /proc/ncsi/eth0/p0/c1
