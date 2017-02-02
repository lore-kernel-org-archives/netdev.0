From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Wed, 1 Feb 2017 18:59:03 -0700
Message-ID: <28b36ff5-a54c-7af6-3cb3-adffa5cfad46@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com>
 <20170202012301.GA74213@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        tgraf@suug.ch, hannes@stressinduktion.org, jbenc@redhat.com,
        pshelar@ovn.org, hadi@mojatatu.com
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34346 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750726AbdBBB7H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 20:59:07 -0500
Received: by mail-pf0-f181.google.com with SMTP id e4so845686pfg.1
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 17:59:07 -0800 (PST)
In-Reply-To: <20170202012301.GA74213@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/1/17 6:23 PM, Alexei Starovoitov wrote:
> On Tue, Jan 31, 2017 at 10:59:50PM -0800, Roopa Prabhu wrote:
>>                     
>> This provides the required vxlan bridging function but poses a
>> scalability problem with using a separate vxlan netdev for each vni.
> if I remember correctly this issue was the main reason David Ahern
> put netdev on diet. Sounds like no more fun at netconf ;)
> 

oh, it still needs a diet ...
