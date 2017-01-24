From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next 1/2] vxlan: don't flush static fdb entries on
 admin down
Date: Mon, 23 Jan 2017 16:14:38 -0800
Message-ID: <58869C6E.8090101@cumulusnetworks.com>
References: <1484984599-16712-1-git-send-email-roopa@cumulusnetworks.com> <1484984599-16712-2-git-send-email-roopa@cumulusnetworks.com> <20170123.160741.1558621534864494201.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ramanb@cumulusnetworks.com,
        stephen@networkplumber.org, jbenc@redhat.com, pshelar@ovn.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f170.google.com ([209.85.192.170]:36168 "EHLO
        mail-pf0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbdAXAPN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:15:13 -0500
Received: by mail-pf0-f170.google.com with SMTP id 189so45060890pfu.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:14:40 -0800 (PST)
In-Reply-To: <20170123.160741.1558621534864494201.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/23/17, 1:07 PM, David Miller wrote:
> From: Roopa Prabhu <roopa@cumulusnetworks.com>
> Date: Fri, 20 Jan 2017 23:43:18 -0800
>
>>  /* Purge the forwarding table */
>> -static void vxlan_flush(struct vxlan_dev *vxlan)
>> +static void vxlan_flush(struct vxlan_dev *vxlan, int do_all)
> Please use 'bool' and true/false for this new argument.
>
> FWIW, I am fine with changing the default behavior in this way.

ack, will fix and post a v2, thanks.
