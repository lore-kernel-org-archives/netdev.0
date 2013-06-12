From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] e1000e: restore call to pci_clear_master()
Date: Wed, 12 Jun 2013 23:05:23 +0400
Message-ID: <51B8C673.50705@cogentembedded.com>
References: <20130612174747.7449.40767.email-sent-by-dnelson@teal> <51B8C035.9010105@cogentembedded.com> <51B8C393.3090100@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Konstantin Khlebnikov <khlebnikov@openvz.org>,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>
To: Dean Nelson <dnelson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f171.google.com ([209.85.217.171]:52279 "EHLO
	mail-lb0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754977Ab3FLTFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 15:05:30 -0400
Received: by mail-lb0-f171.google.com with SMTP id 13so5633969lba.2
        for <netdev@vger.kernel.org>; Wed, 12 Jun 2013 12:05:28 -0700 (PDT)
In-Reply-To: <51B8C393.3090100@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/12/2013 10:53 PM, Dean Nelson wrote:

>>> In attempting to resolve a minor merge conflict, commit
>>> e5f2ef7ab4690d2e8faa
>>> accidently dropped a call to pci_clear_master() that was intended to
>>> remain
>>> in place.

>>> Commit 4e0855dff094b0d56d6b replaced a call to pci_disable_device() by
>>> one to

>>     Please specify the summary line in parens for both commmits you're
>> mentioning.

> Sorry, I'm not understanding fully. Are you asking me to repost the
> patch with the changelog modified, such that each of the commits
> mentioned has their summary statement following, enclosed in parens?

    Exactly.

>>> pci_clear_master(). And then commit 66148babe728f3e00e13 deleted a
>>> number of
>>> lines starting two lines following that call.

>>> This patch restores the call to pci_clear_master() in
>>> __e1000_shutdown().

>>> Signed-off-by: Dean Nelson <dnelson@redhat.com>

[...]

> Also, I mistyped Jeff Kirsher's email address. It's corrected above.
> (Sorry, Jeff.)

    When reposting, you'll have a chance to fix up his email as well. :-)

WBR, Sergei
