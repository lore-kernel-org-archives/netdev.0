From: Marcelo Leitner <mleitner@redhat.com>
Subject: Re: [PATCH 1/1] bonding: properly unset current_arp_slave on slave
 link up
Date: Thu, 05 Apr 2012 17:22:25 -0300
Message-ID: <4F7DFF01.4060309@redhat.com>
References: <20120405134743.GB16870@darkmag.usersys.redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	linux-kernel@vger.kernel.org
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5180 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755584Ab2DEUWb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2012 16:22:31 -0400
In-Reply-To: <20120405134743.GB16870@darkmag.usersys.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/05/2012 10:47 AM, Veaceslav Falico wrote:
> When a slave comes up, we're unsetting the current_arp_slave without
> removing active flags from it, which can lead to situations where we have
> more than one slave with active flags in active-backup mode.
>
> To avoid this situation we must remove the active flags from a slave before
> removing it as a current_arp_slave.
>
> Signed-off-by: Veaceslav Falico<vfalico@redhat.com>

Signed-off-by: Marcelo Ricardo Leitner <mleitner@redhat.com>
