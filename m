From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] e1000e: restore call to pci_clear_master()
Date: Wed, 12 Jun 2013 22:38:45 +0400
Message-ID: <51B8C035.9010105@cogentembedded.com>
References: <20130612174747.7449.40767.email-sent-by-dnelson@teal>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kersher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:58987 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755612Ab3FLSiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 14:38:51 -0400
Received: by mail-lb0-f170.google.com with SMTP id t13so3920366lbd.29
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 11:38:50 -0700 (PDT)
In-Reply-To: <20130612174747.7449.40767.email-sent-by-dnelson@teal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/12/2013 09:47 PM, Dean Nelson wrote:

> In attempting to resolve a minor merge conflict, commit e5f2ef7ab4690d2e8faa
> accidently dropped a call to pci_clear_master() that was intended to remain
> in place.

> Commit 4e0855dff094b0d56d6b replaced a call to pci_disable_device() by one to

    Please specify the summary line in parens for both commmits you're 
mentioning.

> pci_clear_master(). And then commit 66148babe728f3e00e13 deleted a number of
> lines starting two lines following that call.

> This patch restores the call to pci_clear_master() in __e1000_shutdown().

> Signed-off-by: Dean Nelson <dnelson@redhat.com>

WBR, Sergei
