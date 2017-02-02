From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH net-next v2 0/5] bridge: per vlan dst_metadata support
Date: Wed, 01 Feb 2017 20:02:35 -0800
Message-ID: <5892AF5B.3040504@cumulusnetworks.com>
References: <1485932395-58422-1-git-send-email-roopa@cumulusnetworks.com> <20170202012301.GA74213@ast-mbp.thefacebook.com> <28b36ff5-a54c-7af6-3cb3-adffa5cfad46@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        netdev@vger.kernel.org, davem@davemloft.net,
        stephen@networkplumber.org, nikolay@cumulusnetworks.com,
        tgraf@suug.ch, hannes@stressinduktion.org, jbenc@redhat.com,
        pshelar@ovn.org, hadi@mojatatu.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:36591 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750774AbdBBECi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 23:02:38 -0500
Received: by mail-pg0-f43.google.com with SMTP id 3so1803059pgj.3
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 20:02:38 -0800 (PST)
In-Reply-To: <28b36ff5-a54c-7af6-3cb3-adffa5cfad46@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/1/17, 5:59 PM, David Ahern wrote:
> On 2/1/17 6:23 PM, Alexei Starovoitov wrote:
>> On Tue, Jan 31, 2017 at 10:59:50PM -0800, Roopa Prabhu wrote:
>>>                     
>>> This provides the required vxlan bridging function but poses a
>>> scalability problem with using a separate vxlan netdev for each vni.
>> if I remember correctly this issue was the main reason David Ahern
>> put netdev on diet. Sounds like no more fun at netconf ;)
>>
> oh, it still needs a diet ...
 Even if the netdev went on diet, a netdev per vni for vxlan deployments is just too much overhead.
