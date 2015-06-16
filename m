From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 07/17] fm10k: use an unsigned int for i in ethtool_get_strings
Date: Tue, 16 Jun 2015 17:19:01 +0300
Message-ID: <55803055.5030003@cogentembedded.com>
References: <1434462448-140563-1-git-send-email-jeffrey.t.kirsher@intel.com> <1434462448-140563-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:33241 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754358AbbFPOTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2015 10:19:04 -0400
Received: by lblr1 with SMTP id r1so11968997lbl.0
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2015 07:19:02 -0700 (PDT)
In-Reply-To: <1434462448-140563-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/16/2015 4:47 PM, Jeff Kirsher wrote:

> From: Jacob Keller <jacob.e.keller@intel.com>

> The value will never be negative, and we use the %i print format, use

    "%i" is the same as "%d", AFAIR. You need "%u" for the unsigned variables.

> unsigned int for the loop counter. Issue found using cppcheck.

> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Krishneil Singh <Krishneil.k.singh@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

WBR, Sergei
