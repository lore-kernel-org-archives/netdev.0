From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: Re: [PATCH 3/3] vmxnet3: fix typo setting confPA
Date: Fri, 22 Oct 2010 10:39:31 -0700
Message-ID: <AANLkTinBGP1gzUCFN2n1xBGZydEnUKoZYPKd1_WbF1gY@mail.gmail.com>
References: <1287720334-15469-1-git-send-email-harvey.harrison@gmail.com>
	<1287720334-15469-3-git-send-email-harvey.harrison@gmail.com>
	<alpine.LRH.2.00.1010221030530.9726@sbhatewara-dev1.eng.vmware.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: Shreyas Bhatewara <sbhatewara@vmware.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62739 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755694Ab0JVRjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 13:39:32 -0400
Received: by mail-gy0-f174.google.com with SMTP id 4so833473gyg.19
        for <netdev@vger.kernel.org>; Fri, 22 Oct 2010 10:39:32 -0700 (PDT)
In-Reply-To: <alpine.LRH.2.00.1010221030530.9726@sbhatewara-dev1.eng.vmware.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 22, 2010 at 10:31 AM, Shreyas Bhatewara
<sbhatewara@vmware.com> wrote:
> On Thu, 21 Oct 2010, Harvey Harrison wrote:
>
>> It's a le64, not a le32, typo in one place only.
>>
>
> Sure it is. Thanks for the change.
>
> Signed-off-by: Shreyas Bhatewara <sbhatewara@vmware.com>
>
>

One question I had when looking into this, why are you doing
byteswapping in the VMXNET_{READ,WRITE}_BAR{0,1}
macros?

Harvey
